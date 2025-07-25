# Caminho: app/controllers/admin/importacoes_controller.rb
require "securerandom"

module Admin
  class ImportacoesController < Admin::BaseController
    # A herança de Admin::BaseController já deve tratar da autenticação.
    # Esta linha desativa a proteção CSRF do Rails para os métodos de importação.
    skip_before_action :verify_authenticity_token, only: [ :importar_turmas, :importar_alunos ]

    ##
    # Processa a importação de turmas a partir de um arquivo enviado.
    #
    # Descrição: Recebe um arquivo (geralmente CSV ou outro formato esperado)
    #    contendo dados de turmas, delega o processamento para o `TurmaImporterService`
    #    e lida com a resposta para o frontend, indicando sucesso ou falha.
    # Argumentos:
    #    - `params[:file]`: O objeto `UploadedFile` do arquivo enviado para importação.
    # Retorno:
    #    - `JSON`: Retorna um JSON com `notice` e status `:ok` (200) em caso de sucesso total.
    #    - `JSON`: Retorna um JSON com `alert` e `errors` e status `:unprocessable_entity` (422)
    #      em caso de falha total ou parcial na importação.
    # Efeitos colaterais:
    #    - Alterações no banco de dados: O `TurmaImporterService` pode criar ou atualizar
    #      registros nas tabelas `disciplinas` e `turmas`.
    #    - Comunicação via API: Envia respostas JSON ao cliente.
    #    - Exibição de mensagens (notice/alert) no frontend via resposta JSON.
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

    ##
    # Processa a importação de alunos a partir de um arquivo enviado.
    #
    # Descrição: Recebe um arquivo (geralmente CSV ou outro formato esperado)
    #    contendo dados de alunos, delega o processamento para o `AlunoImporterService`
    #    e lida com a resposta para o frontend, detalhando o status da importação.
    # Argumentos:
    #    - `params[:file]`: O objeto `UploadedFile` do arquivo enviado para importação.
    # Retorno:
    #    - `JSON`: Retorna um JSON com `notice` e `details` e status `:ok` (200) em caso de sucesso total.
    #    - `JSON`: Retorna um JSON com `alert`, `errors` e `summary` e status `:multi_status` (207)
    #      em caso de sucesso parcial.
    #    - `JSON`: Retorna um JSON com `alert` e `errors` e status `:unprocessable_entity` (422)
    #      em caso de erro total (ex: arquivo inválido).
    # Efeitos colaterais:
    #    - Alterações no banco de dados: O `AlunoImporterService` pode criar ou atualizar
    #      registros nas tabelas `alunos` e `docentes`.
    #    - Comunicação via API: Envia respostas JSON ao cliente.
    #    - Exibição de mensagens (notice/alert) e detalhes no frontend via resposta JSON.
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
