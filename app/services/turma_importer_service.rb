# Caminho: app/services/turma_importer_service.rb

##
# Serviço para importação de dados de turmas a partir de um arquivo JSON.
#
# Descrição: Esta classe é responsável por ler um arquivo JSON contendo informações
#    de turmas, e persistir esses dados no banco de dados. Ela gerencia a criação
#    ou atualização de disciplinas e turmas, além de lidar com validações e erros
#    durante o processo.
class TurmaImporterService
  ##
  # Inicializa o serviço com o arquivo de importação e contadores.
  #
  # Descrição: O construtor recebe o arquivo a ser processado e inicializa
  #    contadores para o número de turmas criadas e um array para armazenar erros.
  # Argumentos:
  #    - `file`: O objeto de arquivo (e.g., `ActionDispatch::Http::UploadedFile`)
  #      contendo os dados a serem importados.
  # Retorno: Uma nova instância de `TurmaImporterService`.
  # Efeitos colaterais: Inicializa variáveis de instância `@file`, `@turmas_criadas`, `@erros`.
  def initialize(file)
    @file = file
    @turmas_criadas = 0
    @erros = []
  end

  ##
  # Executa o processo de importação de turmas.
  #
  # Descrição: Este é o método principal do serviço. Ele realiza validações iniciais
  #    do arquivo, tenta parsear o conteúdo JSON e, em seguida, chama o método
  #    privado `processar_dados` para realizar a importação. Retorna um hash
  #    com o status da operação (sucesso ou falha) e detalhes sobre as turmas
  #    criadas e/ou erros encontrados.
  # Argumentos: Nenhum.
  # Retorno: Um `Hash` contendo:
  #    - `:success`: `true` se a importação foi bem-sucedida (total ou parcial), `false` caso contrário.
  #    - `:turmas_criadas`: Um `Integer` indicando o número de turmas criadas com sucesso.
  #    - `:errors`: Um `Array` de strings com mensagens de erro, se houver.
  # Efeitos colaterais:
  #    - Leitura do arquivo.
  #    - Parseamento de JSON.
  #    - Chamada a métodos privados que interagem com o banco de dados.
  #    - Retorno de informações de status e erro.
  def call
    # 1. Validações iniciais do arquivo
    unless @file
      return { success: false, errors: [ "Nenhum arquivo foi enviado." ] }
    end

    begin
      turmas_data = JSON.parse(@file.read)
    rescue JSON::ParserError
      return { success: false, errors: [ "Erro: O arquivo não é um JSON válido." ] }
    end

    # 2. Processamento dos dados, que agora vive em um método privado
    processar_dados(turmas_data)

    # 3. Retorno do resultado detalhado, lidando com sucesso parcial
    if @erros.empty?
      { success: true, turmas_criadas: @turmas_criadas }
    else
      {
        success: false,
        turmas_criadas: @turmas_criadas, # Retorna o número de sucessos parciais
        errors: @erros
      }
    end
  end

  private

  ##
  # Processa os dados das turmas contidos no arquivo JSON.
  #
  # Descrição: Itera sobre cada objeto de turma nos dados JSON. Para cada entrada,
  #    tenta encontrar ou criar a disciplina associada e, em seguida, encontrar
  #    ou inicializar a turma. Se a turma for um novo registro, ela é salva
  #    e o contador de turmas criadas é incrementado. Erros individuais são capturados.
  # Argumentos:
  #    - `turmas_data`: Um `Array` de hashes, onde cada hash representa os dados de uma turma.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais:
  #    - Cria ou atualiza registros nas tabelas `disciplinas` e `turmas`.
  #    - Incrementa `@turmas_criadas` em caso de sucesso na criação de uma nova turma.
  #    - Adiciona mensagens de erro ao `@erros` se ocorrer uma exceção durante o processamento de uma turma.
  # Este método contém a sua lógica original de processamento, sem alterações.
  def processar_dados(turmas_data)
    turmas_data.each_with_index do |turma_info, index|
      begin
        # Encontra ou cria a disciplina associada
        disciplina = Disciplina.find_or_create_by!(codigo: turma_info["code"]) do |d|
          d.nome = turma_info["name"]
        end

        class_info = turma_info["class"]
        unless class_info
          @erros << "Linha #{index + 1}: Faltam informações da turma (objeto 'class')."
          next
        end

        # Encontra ou inicializa a turma
        turma = Turma.find_or_initialize_by(
          disciplina: disciplina,
          codigo_turma: class_info["classCode"],
          semestre: class_info["semester"]
        )

        # Salva apenas se for um novo registro
        if turma.new_record?
          turma.save!
          @turmas_criadas += 1
        end
      rescue => e
        @erros << "Linha #{index + 1}: #{e.message}"
      end
    end
  end
end
