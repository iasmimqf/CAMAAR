# app/controllers/api/v1/templates_controller.rb
module Api
  module V1
    class TemplatesController < ApplicationController
      # MUITO IMPORTANTE: Ajuste do skip_before_action para incluir :destroy
      # e remover :index (pois GET não precisa de CSRF token)
      skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy]
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
      def show
        template = Template.find(params[:id])
        # MUITO IMPORTANTE: incluir as questoes na resposta JSON
        render json: template.as_json(include: :questoes), status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Template não encontrado" }, status: :not_found
      rescue => e
        render json: { error: "Ocorreu um erro ao buscar o template: #{e.message}" }, status: :internal_server_error
      end
      # GET /api/v1/templates/:id
    

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

      # PUT/PATCH /api/v1/templates/:id
      def update
        template = Template.find(params[:id]) # Encontra o template pelo ID
        # Tenta atualizar o template com os novos parâmetros
        if template.update(template_params)
          # Se a atualização for bem-sucedida, retorna uma mensagem e o template atualizado
          render json: { mensagem: "Template '#{template.titulo}' atualizado com sucesso", template: template }, status: :ok
        else
          # Se houver erros de validação, retorna os erros com status 422
          render json: { erro: template.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        # Se o template não for encontrado, retorna 404 Not Found
        render json: { error: "Template não encontrado" }, status: :not_found
      rescue => e
        # Captura outros erros inesperados durante a atualização
        render json: { erro: e.message }, status: :bad_request
      end

      # NOVO: Método para excluir um template
      # DELETE /api/v1/templates/:id
      def destroy
        template = Template.find(params[:id]) # Encontra o template pelo ID
        # Aqui você pode adicionar uma lógica de negócio, como:
        # - Verificar se existem formulários associados (conforme seu Gherkin)
        #   if template.formularios.any?
        #     render json: { erro: "Não é possível excluir o template pois existem formulários associados a ele." }, status: :conflict
        #     return # Interrompe a execução aqui
        #   end

        template.destroy # Exclui o template e suas questões (devido a dependent: :destroy no modelo Template)
        render json: { mensagem: "Template '#{template.titulo}' excluído com sucesso" }, status: :no_content # 204 No Content para sucesso sem retorno de corpo
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Template não encontrado" }, status: :not_found
      rescue => e
        render json: { error: "Ocorreu um erro ao excluir o template: #{e.message}" }, status: :internal_server_error
      end

      private

      # Método para permitir apenas os parâmetros seguros e esperados
      # `questoes_attributes` é crucial para salvar as questões aninhadas
      def template_params
        params.require(:template).permit(
          :titulo,
          # Adicionar :id aqui é crucial para que accepts_nested_attributes_for saiba qual questão atualizar
          # e para que _destroy funcione corretamente para remover questões.
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