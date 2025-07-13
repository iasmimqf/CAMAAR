class Admin::Import::AlunosController < Admin::BaseController
  def new
  end

  def create
    file = params[:file]
    unless file
      redirect_to new_admin_import_aluno_path, alert: "Nenhum arquivo enviado."
      return
    end

    # Verifica se o nome do arquivo termina com .json
    unless file.original_filename.end_with?('.json')
      redirect_to admin_dashboard_path, alert: "Formato de arquivo inválido. Por favor, envie um arquivo .json."
      return
    end

    begin
      file_content = File.read(file.path)
      import_data = JSON.parse(file_content).first

      # --- 1. Encontrar a Turma ---
      disciplina = Disciplina.find_by(codigo: import_data["code"])
      unless disciplina
        # Se a disciplina não existe, não podemos continuar.
        redirect_to new_admin_import_aluno_path, alert: "Erro: A disciplina com código #{import_data['code']} não foi encontrada. Importe o arquivo de turmas primeiro."
        return
      end

      turma = disciplina.turmas.find_by(
        codigo_turma: import_data["classCode"],
        semestre:   import_data["semester"]
      )
      unless turma
        redirect_to new_admin_import_aluno_path, alert: "Erro: A turma #{import_data['classCode']} do semestre #{import_data['semester']} não foi encontrada."
        return
      end

      # --- 2. Processar o Professor (Docente) ---
      if import_data["docente"].present?
        docente_info = import_data["docente"]
        # Usamos a matrícula ou o e-mail como identificador único. A matrícula é geralmente melhor.
        professor = Usuario.find_or_create_by!(matricula: docente_info["usuario"]) do |u|
          u.nome = docente_info["nome"]
          u.email = docente_info["email"]
          u.password = 'senha_padrao_123'
          u.password_confirmation = 'senha_padrao_123'
        end

        # Associa o professor à turma
        turma.update(professor: professor)
      end

      # --- 3. Processar os Alunos (Dicente) ---
      if import_data["dicente"].present?
        import_data["dicente"].each do |aluno_info|
          # Encontra o aluno pela matrícula ou cria um novo
          aluno = Usuario.find_or_create_by!(matricula: aluno_info["matricula"]) do |u|
            u.nome = aluno_info["nome"]
            u.email = aluno_info["email"]
            u.password = 'senha_padrao_123'
            u.password_confirmation = 'senha_padrao_123'
          end

          # Adiciona o 'aluno' à coleção 'usuarios' da 'turma',
          # a menos que a associação já exista.
          turma.usuarios << aluno unless turma.usuario_ids.include?(aluno.id)
        end
      end

      redirect_to new_admin_import_aluno_path, notice: "Arquivo de alunos processado com sucesso!"

    rescue JSON::ParserError
      redirect_to new_admin_import_aluno_path, alert: "Erro ao processar o arquivo. Verifique a sintaxe do JSON."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to new_admin_import_aluno_path, alert: "Erro de validação: #{e.message}"
    end
  end
end