# Caminho: app/controllers/admin/importacoes_controller.rb
module Admin
  class ImportacoesController < Admin::BaseController
    # A herança de Admin::BaseController já deve tratar da autenticação.
    # Esta linha desativa a proteção CSRF do Rails para os métodos de importação.
    skip_before_action :verify_authenticity_token, only: [ :importar_turmas, :importar_alunos, :importar_csv_sigaa ]

    # GET /admin/importacoes/new_turma
    def new_turma
      render :new_turma
    end

    # GET /admin/importacoes/new_aluno
    def new_aluno
      render :new_aluno
    end

    # POST /admin/importacoes/importar_csv_sigaa
    def importar_csv_sigaa
      if params[:file].blank?
        render json: { alert: "Nenhum arquivo foi selecionado" }, status: :bad_request
        return
      end

      arquivo = params[:file]
      
      # Verifica se é um arquivo CSV
      unless arquivo.content_type == 'text/csv' || arquivo.original_filename.end_with?('.csv')
        render json: { alert: "O arquivo deve ser do formato CSV" }, status: :unprocessable_entity
        return
      end

      begin
        require 'csv'
        
        # Lê o conteúdo do arquivo CSV
        csv_data = arquivo.read.force_encoding('UTF-8')
        
        # Parse do CSV
        dados = CSV.parse(csv_data, headers: true)
        
        if dados.empty?
          render json: { alert: "O arquivo CSV está vazio" }, status: :unprocessable_entity
          return
        end

        # Processa os dados do CSV
        erros = []
        sucessos = 0
        usuarios_criados = 0

        dados.each_with_index do |linha, index|
          begin
            # Converte a linha para hash
            dados_linha = linha.to_h
            
            # Valida campos obrigatórios
            nome = dados_linha['nome']&.strip
            email = dados_linha['email']&.strip
            matricula = dados_linha['matricula']&.strip
            
            if nome.blank? || email.blank? || matricula.blank?
              erros << "Linha #{index + 2}: campos obrigatórios em branco (nome, email, matricula)"
              next
            end
            
            # Tenta criar ou atualizar o usuário
            usuario = Usuario.find_or_initialize_by(email: email)
            usuario.assign_attributes(
              nome: nome,
              matricula: matricula,
              login: email, # Usa email como login
              password: 'DefaultPassword123!' # Senha padrão que deve ser alterada
            )
            
            if usuario.save
              usuarios_criados += 1 if usuario.previously_new_record?
              sucessos += 1
            else
              erros << "Linha #{index + 2}: #{usuario.errors.full_messages.join(', ')}"
            end
            
          rescue => e
            erros << "Linha #{index + 2}: #{e.message}"
          end
        end

        if erros.empty?
          render json: { notice: "Dados importados com sucesso do SIGAA" }, status: :ok
        else
          render json: { alert: "Erro ao importar dados do SIGAA: #{erros.join('; ')}" }, status: :unprocessable_entity
        end

      rescue CSV::MalformedCSVError => e
        render json: { alert: "Erro ao importar dados do SIGAA: formato CSV inválido" }, status: :unprocessable_entity
      rescue => e
        render json: { alert: "Erro ao importar dados do SIGAA: #{e.message}" }, status: :unprocessable_entity
      end
    end

    # POST /admin/importacoes/importar_turmas
    def importar_turmas
      file = params[:file] || params[:arquivo]

      # 1. Validação inicial: verifica se um ficheiro foi enviado
      unless file
        render json: { alert: "Nenhum ficheiro foi enviado." }, status: :bad_request
        return
      end

      # 2. Lê e analisa o ficheiro JSON
      begin
        turmas_data = JSON.parse(file.read)
      rescue JSON::ParserError
        render json: { alert: "Erro: O ficheiro não é um JSON válido." }, status: :unprocessable_entity
        return
      end

      # 3. Processa cada item do JSON para criar as turmas
      erros = []
      turmas_criadas = 0

      turmas_data.each_with_index do |turma_info, index|
        begin
          # --- CÓDIGO ATUALIZADO PARA O SEU JSON ---
          # Encontra ou cria a disciplina associada
          disciplina = Disciplina.find_or_create_by!(codigo: turma_info["code"]) do |d|
            d.nome = turma_info["name"]
          end

          # Acede ao objeto aninhado 'class'
          class_info = turma_info["class"]
          unless class_info
            erros << "Linha #{index + 1}: Faltam informações da turma (objeto 'class')."
            next # Pula para a próxima iteração
          end

          # Encontra o professor pelo e-mail (opcional, não será encontrado no seu JSON de exemplo)
          professor = Usuario.find_by(email: turma_info["professor_email"]) if turma_info["professor_email"].present?

          # Cria a turma, evitando duplicados
          turma = Turma.find_or_initialize_by(
            disciplina: disciplina,
            codigo_turma: class_info["classCode"],
            semestre: class_info["semester"]
          )

          # Se for uma turma nova, associa o professor
          if turma.new_record?
            turma.professor = professor
            turma.save!
            turmas_criadas += 1
          end
          # --- FIM DA ATUALIZAÇÃO ---

        rescue => e
          # Captura qualquer erro durante a criação e adiciona à lista
          erros << "Linha #{index + 1}: #{e.message}"
        end
      end

      # 4. Retorna uma resposta em JSON para o frontend
      if erros.empty?
        render json: { notice: "#{turmas_criadas} turmas importadas com sucesso!" }, status: :ok
      else
        render json: { alert: "Importação concluída com erros: #{erros.join(', ')}" }, status: :unprocessable_entity
      end
    end

    # --- NOVO MÉTODO PARA ALUNOS ---
    # POST /admin/importacoes/importar_alunos
    def importar_alunos
      file = params[:file] || params[:arquivo]

      unless file
        return render json: { alert: "Nenhum ficheiro foi enviado." }, status: :bad_request
      end

      begin
        alunos_data = JSON.parse(file.read)
      rescue JSON::ParserError
        return render json: { alert: "Erro: O ficheiro não é um JSON válido." }, status: :unprocessable_entity
      end

      erros = []
      alunos_criados_ou_atualizados = 0

      # Processa cada turma no JSON
      alunos_data.each_with_index do |turma_data, turma_index|
        # Extrai informações da turma
        codigo_disciplina = turma_data["code"]
        codigo_turma = turma_data["classCode"]
        semestre = turma_data["semester"]
        
        # Encontra ou cria a disciplina
        disciplina = Disciplina.find_or_create_by(codigo: codigo_disciplina) do |d|
          d.nome = "Disciplina #{codigo_disciplina}" # nome padrão se não existir
        end
        
        # Encontra ou cria a turma
        turma = disciplina.turmas.find_or_create_by!(
          codigo_turma: codigo_turma,
          semestre: semestre
        )
        
        # Processa cada aluno (dicente) na turma
        dicentes = turma_data["dicente"] || []
        dicentes.each_with_index do |aluno_info, aluno_index|
          begin
            # Encontra o aluno pela matrícula ou cria um novo
            aluno = Usuario.find_or_initialize_by(matricula: aluno_info["matricula"])
            if aluno.new_record?
              aluno.nome = aluno_info["nome"]
              aluno.email = aluno_info["email"]
              aluno.password = "SenhaPadrao123!" # Defina uma senha padrão segura
              aluno.password_confirmation = "SenhaPadrao123!"
              aluno.save!
              alunos_criados_ou_atualizados += 1
            end

            # Associa o aluno à turma (se ainda não estiver associado)
            unless aluno.turmas.include?(turma)
              aluno.turmas << turma
            end
          rescue => e
            erros << "Turma #{turma_index + 1}, Aluno #{aluno_index + 1} (Matrícula: #{aluno_info['matricula']}): #{e.message}"
          end
        end
      end

      if erros.empty?
        render json: { notice: "#{alunos_criados_ou_atualizados} alunos importados/atualizados com sucesso!" }, status: :ok
      else
        render json: { alert: "Importação concluída com erros: #{erros.join('; ')}" }, status: :unprocessable_entity
      end
    end
  end
end
