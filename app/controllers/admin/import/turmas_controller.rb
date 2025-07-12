class Admin::Import::TurmasController < Admin::BaseController
  def create
    file = params[:file]
    unless file
      redirect_to new_admin_import_turma_path, alert: "Nenhum arquivo enviado."
      return
    end

    begin
      # Lê o conteúdo do arquivo JSON
      file_content = File.read(file.path)
      turmas_data = JSON.parse(file_content)

      # Itera sobre cada objeto de turma no arquivo JSON
      turmas_data.each do |turma_info|
        # 1. Encontra a disciplina pelo código ou a cria se não existir.
        disciplina = Disciplina.find_or_create_by!(
          codigo: turma_info["code"],
          nome: turma_info["name"]
        )
        # 2. Dentro do escopo da disciplina, encontra a turma ou a cria.
        #    O 'disciplina.turmas' garante que a nova turma será automaticamente
        #    associada à disciplina correta.
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
      redirect_to new_admin_import_turma_path, alert: "Erro ao processar o arquivo. Verifique a sintaxe do JSON."
    rescue ActiveRecord::RecordInvalid => e
      # Lida com erros de validação (ex: um campo obrigatório está faltando)
      redirect_to new_admin_import_turma_path, alert: "Erro de validação: #{e.message}"
    end
    # --- FIM DA LÓGICA DE IMPORTAÇÃO ---
  end
end