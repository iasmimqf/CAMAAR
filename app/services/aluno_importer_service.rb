# app/services/aluno_importer_service.rb
class AlunoImporterService
  # O service é inicializado com o arquivo enviado
  def initialize(file)
    @file = file
    @novos_alunos = 0
    @novos_docentes = 0
  end

  # O método 'call' é o que executa o trabalho pesado
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
          errors: erros,
          success_summary: {
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

  def processar_docente(docente_info, turma, index, erros)
    return unless docente_info.present?

    professor = Usuario.find_or_initialize_by(matricula: docente_info["usuario"])
    if professor.new_record?
      professor.assign_attributes(
        nome: docente_info["nome"],
        email: docente_info["email"],
        password: SecureRandom.urlsafe_base64(20) + "Aa!2"
      )
      professor.save!
      professor.send_reset_password_instructions
      @novos_docentes += 1
    end
    turma.update!(professor: professor)
  rescue => e
    erros << "Turma #{index + 1}: Erro ao associar docente (#{e.message})"
  end

  def processar_discentes(discentes_info, turma, index, erros)
    return unless discentes_info.present?

    discentes_info.each_with_index do |aluno_info, aluno_index|
      aluno = Usuario.find_or_initialize_by(matricula: aluno_info["matricula"])
      if aluno.new_record?
        aluno.assign_attributes(
          nome: aluno_info["nome"],
          email: aluno_info["email"],
          password: SecureRandom.urlsafe_base64(20) + "Aa!2"
        )
        aluno.save!
        aluno.send_reset_password_instructions
        @novos_alunos += 1
      end
      turma.usuarios << aluno unless turma.usuarios.include?(aluno)
    rescue => e
      erros << "Turma #{index + 1}, Aluno #{aluno_index + 1}: #{e.message}"
    end
  end
end
