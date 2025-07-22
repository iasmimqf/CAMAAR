# app/services/turma_importer_service.rb
class TurmaImporterService
  # Inicializa com o arquivo e os contadores
  def initialize(file)
    @file = file
    @turmas_criadas = 0
    @erros = []
  end

  # O método principal que orquestra a importação
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
