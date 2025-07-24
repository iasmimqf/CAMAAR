# Caminho: app/controllers/api/v1/templates_controller.rb
module Api
  module V1
    class TemplatesController < Api::V1::BaseController
      before_action :authenticate_admin_access!
      before_action :set_template, only: [:show, :update, :destroy]

      # GET /api/v1/templates
      def index
        templates = Template.order(created_at: :desc)
        render json: templates.to_json(only: [ :id, :titulo, :created_at ])
      end

      # GET /api/v1/templates/:id
      def show
        render json: @template.to_json(include: { questoes: { methods: :opcoes_array } })
      end

      # POST /api/v1/templates
      def create
        @template = Template.new(template_params.merge(criador_id: current_usuario.id))
        if @template.save
          render json: { mensagem: "Template '#{@template.titulo}' salvo com sucesso", template: @template }, status: :created
        else
          render json: { erro: @template.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/templates/:id
      def update
        if @template.update(template_params)
          render json: { mensagem: "Template '#{@template.titulo}' atualizado com sucesso", template: @template }, status: :ok
        else
          render json: { erro: @template.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # ===============================================================
      # ▼▼▼ MÉTODO DESTROY CORRIGIDO COM MENSAGEM AMIGÁVEL ▼▼▼
      # ===============================================================
      # DELETE /api/v1/templates/:id
      def destroy
        if @template.destroy
          render json: { mensagem: "Template '#{@template.titulo}' excluído com sucesso" }, status: :ok
        else
          # Personaliza a mensagem de erro para ser mais clara para o utilizador.
          # A regra `restrict_with_error` adiciona o erro ao atributo :base do modelo.
          error_message = if @template.errors.key?(:base)
                            "Este template não pode ser excluído porque já está a ser utilizado por um ou mais formulários."
                          else
                            # Para outros erros de validação, usa a mensagem padrão.
                            @template.errors.full_messages.join(', ')
                          end
          render json: { erro: error_message }, status: :unprocessable_entity
        end
      end
      # ===============================================================

      private

      def set_template
        @template = Template.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Template não encontrado." }, status: :not_found
      end

      def template_params
        params.require(:template).permit(
          :titulo,
          questoes_attributes: [
            :id, :tipo, :enunciado, :obrigatoria, { opcoes: [] }, :_destroy
          ]
        )
      end
    end
  end
end
