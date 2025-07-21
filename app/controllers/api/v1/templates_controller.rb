# Caminho: app/controllers/api/v1/templates_controller.rb
module Api
  module V1
    # <<< ALTERADO: Agora herda do nosso novo BaseController
    class TemplatesController < Api::V1::BaseController
      # O filtro de segurança agora vem do BaseController.
      before_action :authenticate_admin_access!
      before_action :set_template, only: [:show, :update, :destroy]

      # GET /api/v1/templates
      def index
        templates = Template.order(created_at: :desc)
        render json: templates.to_json(only: [:id, :titulo, :created_at])
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

      # DELETE /api/v1/templates/:id
      def destroy
        @template.destroy
        render json: { mensagem: "Template '#{@template.titulo}' excluído com sucesso" }, status: :ok
      end

      private

      def set_template
        @template = Template.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Template não encontrado.' }, status: :not_found
      end

      def template_params
        params.require(:template).permit(
          :titulo,
          questoes_attributes: [
            :id, :tipo, :enunciado, :obrigatoria, { opcoes: [] }, :_destroy
          ]
        )
      end
      
      # <<< REMOVIDO: A lógica de authenticate_admin! foi movida para o BaseController
    end
  end
end