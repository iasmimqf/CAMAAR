class ImportValidationError < StandardError; end
class Admin::Import::TurmasController < Admin::BaseController

  def new
  end
  def create
    file = params[:file]
    unless file
      redirect_to new_admin_import_turma_path, alert: "Nenhum arquivo enviado."
      return
    end
    # Verifica se o nome do arquivo termina com .json
    unless file.original_filename.end_with?('.json')
      redirect_to admin_dashboard_path, alert: "Formato de arquivo inválido. Por favor, envie um arquivo .json."
      return
    end
    begin
      # Lê o conteúdo do arquivo JSON
      file_content = File.read(file.path)
      turmas_data = JSON.parse(file_content)

      turmas_data.each do |turma_info|
        if turma_info["code"].blank? || turma_info["name"].blank?
          # Lança nosso erro customizado
          raise ImportValidationError, "'code' e 'name' são obrigatórios para a disciplina."
        end
        if turma_info["class"].blank? || turma_info["class"]["classCode"].blank? || turma_info["class"]["semester"].blank?
          raise ImportValidationError, "a estrutura 'class' com 'classCode' e 'semester' é obrigatória."
        end
      end

      # Processamento dos dados
      turmas_data.each do |turma_info|
        disciplina = Disciplina.find_or_create_by!(codigo: turma_info["code"]) do |d|
          d.nome = turma_info["name"]
        end

        disciplina.turmas.find_or_create_by!(
          codigo_turma: turma_info["class"]["classCode"],
          semestre: turma_info["class"]["semester"]
        ) do |t|
          t.horario = turma_info["class"]["time"]
        end
      end

      redirect_to new_admin_import_turma_path, notice: "Arquivo de turmas processado com sucesso!"

    rescue JSON::ParserError
      # Lida com o erro de JSON malformado (Sad Path)
      redirect_to admin_dashboard_path, alert: "Erro ao processar o arquivo. Verifique a sintaxe do JSON."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_dashboard_path, alert: "Erro de validação: #{e.message}"
    rescue ImportValidationError => e # <-- CAPTURA O NOSSO ERRO CUSTOMIZADO
      # Redireciona com a mensagem do erro que nós criamos
      redirect_to admin_dashboard_path, alert: "Erro na estrutura do arquivo: #{e.message}"
    end
  end
end