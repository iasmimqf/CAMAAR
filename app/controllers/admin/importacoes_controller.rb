# Caminho: app/controllers/admin/importacoes_controller.rb
require 'securerandom'

module Admin
  class ImportacoesController < Admin::BaseController
    # A herança de Admin::BaseController já deve tratar da autenticação.
    # Esta linha desativa a proteção CSRF do Rails para os métodos de importação.
    skip_before_action :verify_authenticity_token, only: [ :importar_turmas, :importar_alunos ]

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

    def importar_alunos
      resultado = AlunoImporterService.new(params[:file]).call

      case resultado[:status]
      when :success
        # Sucesso total
        details = resultado[:details]
        notice = "Importação concluída!\n#{details[:alunos_criados]} novos alunos e #{details[:docentes_criados]} novos professores foram cadastrados."
        render json: { notice: notice, details: details }, status: :ok

      when :partial_success
        # Sucesso parcial
        summary = resultado[:success_summary]
        alert = "Importação concluída com erros.\n#{summary[:alunos_criados]} alunos e #{summary[:docentes_criados]} professores foram processados com sucesso."
        render json: { alert: alert, errors: resultado[:errors], summary: summary }, status: :multi_status # 207 Multi-Status

      when :error
        # Erro completo (ex: JSON inválido)
        render json: { alert: "Falha na importação.", errors: resultado[:errors] }, status: :unprocessable_entity
      end
    end
  end
end
