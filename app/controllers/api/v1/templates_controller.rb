# app/controllers/api/v1/templates_controller.rb
module Api
  module V1
    class TemplatesController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [:create]
      # Considerar autenticação aqui, ex: before_action :authenticate_request
      # Por enquanto, para teste, você pode deixar sem autenticação se for rodar localmente
      # Se você tiver um método de autenticação, adicione-o aqui, por exemplo:
      # before_action :authenticate_admin! # Substitua por seu método de autenticação real

      # GET /api/v1/templates
      def index
        templates = Template.all # Busca todos os templates do seu banco de dados
        render json: templates, status: :ok # Retorna eles como JSON
      rescue => e
        # Em produção, você registraria este erro.
        render json: { error: "Ocorreu um erro ao buscar templates: #{e.message}" }, status: :internal_server_error
      end

      # POST /api/v1/templates
      def create
        # Cria uma nova instância de Template com os parâmetros recebidos
        template = Template.new(template_params)

        if template.save
          # Se o template for salvo com sucesso, retorna uma mensagem e o template criado
          render json: { mensagem: "Template '#{template.titulo}' salvo com sucesso", template: template }, status: :created
        else
          # Se houver erros de validação (ex: título em branco, questões incompletas),
          # retorna os erros com status 422 (Unprocessable Entity)
          render json: { erro: template.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique
        # Captura erro se tentar criar um template com título já existente
        render json: { erro: "Já existe um template com este nome. Use um título diferente." }, status: :conflict
      rescue => e
        # Captura outros erros inesperados durante a criação
        render json: { erro: e.message }, status: :bad_request # ou outro status mais específico
      end

      # TODO: Implementar os métodos update e destroy futuramente
      # PUT/PATCH /api/v1/templates/:id
      # def update
      #   # Lógica para atualizar um template existente
      # end

      # DELETE /api/v1/templates/:id
      # def destroy
      #   # Lógica para excluir um template
      # end

      private

      # Método para permitir apenas os parâmetros seguros e esperados
      # `questoes_attributes` é crucial para salvar as questões aninhadas
      def template_params
        params.require(:template).permit(
          :titulo,
          questoes_attributes: [
            :id, # Importante para edição/remoção de questões existentes
            :tipo,
            :enunciado,
            :obrigatoria,
            { opcoes: [] }, # Permite que 'opcoes' seja um array
            :_destroy # Importante para permitir a remoção de questões aninhadas
          ]
        )
      end
    end
  end
end