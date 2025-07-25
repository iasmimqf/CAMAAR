# Caminho: app/services/aluno_importer_service.rb

##
# Serviço para importação de dados de alunos e docentes a partir de um arquivo JSON.
#
# Descrição: Esta classe é responsável por ler um arquivo JSON contendo informações
#    de turmas, docentes e discentes, e persistir esses dados no banco de dados.
#    Ela gerencia a criação ou atualização de usuários (alunos e professores),
#    disciplinas e turmas, além de lidar com validações e erros durante o processo.
class AlunoImporterService
  ##
  # Inicializa o serviço com o arquivo de importação.
  #
  # Descrição: O construtor recebe o arquivo a ser processado e inicializa
  #    contadores para novos alunos e docentes criados.
  # Argumentos:
  #    - `file`: O objeto de arquivo (e.g., `ActionDispatch::Http::UploadedFile`)
  #      contendo os dados a serem importados.
  # Retorno: Uma nova instância de `AlunoImporterService`.
  # Efeitos colaterais: Inicializa variáveis de instância `@file`, `@novos_alunos`, `@novos_docentes`.
  def initialize(file)
    @file = file
    @novos_alunos = 0
    @novos_docentes = 0
  end

  ##
  # Executa o processo de importação.
  #
  # Descrição: Este é o método principal do serviço. Ele valida o arquivo,
  #    lê e parseia o conteúdo JSON, e chama `processar_dados` para realizar
  #    a importação. Retorna um hash com o status da operação (sucesso,
  #    sucesso parcial ou erro) e detalhes/erros.
  # Argumentos: Nenhum.
  # Retorno: Um `Hash` contendo:
  #    - `:status`: `:success`, `:partial_success` ou `:error`.
  #    - `:details` (se `:success`): Hash com `alunos_criados` e `docentes_criados`.
  #    - `:errors` (se `:partial_success` ou `:error`): Array de strings com mensagens de erro.
  #    - `:success_summary` (se `:partial_success`): Hash com `alunos_criados` e `docentes_criados`.
  # Efeitos colaterais:
  #    - Leitura do arquivo.
  #    - Parseamento de JSON.
  #    - Chamada a métodos privados que interagem com o banco de dados.
  #    - Retorno de informações de status e erro.
  def call
    # Validação inicial do arquivo
    return { success: false, errors: [ "Nenhum arquivo foi enviado." ] } unless @file
    return { success: false, errors: [ "Formato inválido. Envie um arquivo .json." ] } unless @file.original_filename.end_with?(".json")

    begin
      turmas_data = JSON.parse(@file.read)
      erros = processar_dados(turmas_data)

      if erros.empty?
        {
          status: :success,
          details: {
            alunos_criados: @novos_alunos,
            docentes_criados: @novos_docentes
          }
        }
      else
        {
          status: :partial_success,
          erros: erros,
          sucesso: {
            alunos_criados: @novos_alunos,
            docentes_criados: @novos_docentes
          }
        }
      end
    rescue JSON::ParserError
      { status: :error, errors: [ "Erro: JSON inválido." ] }
    end
  end

  private

  ##
  # Processa os dados das turmas contidos no arquivo JSON.
  #
  # Descrição: Itera sobre cada objeto de turma nos dados JSON. Para cada turma,
  #    tenta encontrar a disciplina e a turma correspondente no banco de dados.
  #    Se não encontradas, registra um erro. Em seguida, chama métodos para
  #    processar o docente e os discentes associados à turma.
  # Argumentos:
  #    - `turmas_data`: Um `Array` de hashes, onde cada hash representa os dados de uma turma.
  # Retorno: Um `Array` de strings contendo as mensagens de erro acumuladas durante o processamento.
  # Efeitos colaterais:
  #    - Interage com os modelos `Disciplina` e `Turma` para encontrar registros.
  #    - Chama `processar_docente` e `processar_discentes`.
  def processar_dados(turmas_data)
    erros = []

    turmas_data.each_with_index do |turma_info, index|
      disciplina = Disciplina.find_by(codigo: turma_info["code"])
      unless disciplina
        erros << "Turma #{index + 1}: Disciplina #{turma_info['code']} não encontrada."
        next
      end

      turma = disciplina.turmas.find_by(codigo_turma: turma_info["classCode"], semestre: turma_info["semester"])
      unless turma
        erros << "Turma #{index + 1}: Turma #{turma_info['classCode']} não encontrada."
        next
      end

      processar_docente(turma_info["docente"], turma, index, erros)
      processar_discentes(turma_info["dicente"], turma, index, erros)
    end

    erros
  end

  ##
  # Processa os dados de um docente (professor) e o associa a uma turma.
  #
  # Descrição: Recebe as informações de um docente. Tenta encontrar um usuário
  #    existente pela matrícula ou inicializa um novo. Se for um novo registro,
  #    atribui nome, e-mail e uma senha temporária, salva o usuário e envia
  #    instruções de redefinição de senha. Finalmente, atualiza a turma com o professor.
  # Argumentos:
  #    - `docente_info`: Um `Hash` contendo os dados do docente (e.g., `usuario`, `nome`, `email`).
  #    - `turma`: O objeto `Turma` ao qual o docente será associado.
  #    - `index`: O índice da turma no array de dados original (para mensagens de erro).
  #    - `erros`: O `Array` de strings para acumular mensagens de erro.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais:
  #    - Cria ou atualiza um registro na tabela `usuarios` (para o professor).
  #    - Envia e-mail de redefinição de senha para novos professores.
  #    - Atualiza o atributo `professor` da `Turma`.
  #    - Adiciona mensagens de erro ao `erros` se ocorrer uma exceção.
  def processar_docente(docente_info, turma, index, erros)
    return unless docente_info.present?

    professor = Usuario.find_or_initialize_by(matricula: docente_info["usuario"])
    if professor.new_record?
      professor.assign_attributes(
        nome: docente_info["nome"],
        email: docente_info["email"],
        password: SecureRandom.urlsafe_base64(20) + "Aa!2" # Senha temporária
      )
      professor.save!
      professor.send_reset_password_instructions # Envia e-mail para definir senha
      @novos_docentes += 1
    end
    turma.update!(professor: professor)
  rescue => e
    erros << "Turma #{index + 1}: Erro ao associar docente (#{e.message})"
  end

  ##
  # Processa os dados dos discentes (alunos) e os associa a uma turma.
  #
  # Descrição: Itera sobre as informações dos discentes. Para cada aluno,
  #    tenta encontrar um usuário existente pela matrícula ou inicializa um novo.
  #    Se for um novo registro, atribui nome, e-mail e uma senha temporária,
  #    salva o usuário e envia instruções de redefinição de senha.
  #    Finalmente, associa o aluno à turma.
  # Argumentos:
  #    - `discentes_info`: Um `Array` de hashes, onde cada hash representa os dados de um discente.
  #    - `turma`: O objeto `Turma` ao qual os discentes serão associados.
  #    - `index`: O índice da turma no array de dados original (para mensagens de erro).
  #    - `erros`: O `Array` de strings para acumular mensagens de erro.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais:
  #    - Cria ou atualiza registros na tabela `usuarios` (para os alunos).
  #    - Envia e-mail de redefinição de senha para novos alunos.
  #    - Associa alunos à `Turma` através da tabela de junção.
  #    - Adiciona mensagens de erro ao `erros` se ocorrer uma exceção.
  def processar_discentes(discentes_info, turma, index, erros)
    return unless discentes_info.present?

    discentes_info.each_with_index do |aluno_info, aluno_index|
      aluno = Usuario.find_or_initialize_by(matricula: aluno_info["matricula"])
      if aluno.new_record?
        aluno.assign_attributes(
          nome: aluno_info["nome"],
          email: aluno_info["email"],
          password: SecureRandom.urlsafe_base64(20) + "Aa!2" # Senha temporária
        )
        aluno.save!
        aluno.send_reset_password_instructions # Envia e-mail para definir senha
        @novos_alunos += 1
      end
      turma.usuarios << aluno unless turma.usuarios.include?(aluno)
    rescue => e
      erros << "Turma #{index + 1}, Aluno #{aluno_index + 1}: #{e.message}"
    end
  end
end
