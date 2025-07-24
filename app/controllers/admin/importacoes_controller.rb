# Caminho: app/controllers/admin/importacoes_controller.rb
require "securerandom"

module Admin
  class ImportacoesController < Admin::BaseController
    # A herança de Admin::BaseController já deve tratar da autenticação.
    # Esta linha desativa a proteção CSRF do Rails para os métodos de importação.
    skip_before_action :verify_authenticity_token, only: [ :importar_turmas, :importar_alunos ]

    # POST /admin/importacoes/importar_turmas
    def importar_turmas
      # O controller apenas delega o trabalho para o serviço
      resultado = TurmaImporterService.new(params[:file]).call

      # E lida com a resposta para o frontend
      if resultado[:success]
        render json: { notice: "#{resultado[:turmas_criadas]} turmas importadas com sucesso!" }, status: :ok
      else
        # Se houve falha (total ou parcial), retorna os detalhes
        alert_message = "Importação concluída com erros."
        alert_message += " #{resultado[:turmas_criadas].to_i} turmas foram importadas com sucesso." if resultado[:turmas_criadas].to_i > 0

        render json: {
          alert: alert_message,
          errors: resultado[:errors]
        }, status: :unprocessable_entity
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
