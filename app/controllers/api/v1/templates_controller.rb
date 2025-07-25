# Caminho: app/controllers/api/v1/templates_controller.rb
module Api
  module V1
    class TemplatesController < Api::V1::BaseController
      # Garante que apenas administradores autenticados possam acessar as ações deste controlador.
      before_action :authenticate_admin_access!
      # Define o template antes de certas ações para evitar duplicação de código.
      before_action :set_template, only: [:show, :update, :destroy]

      ##
      # Lista todos os templates disponíveis.
      #
      # Descrição: Busca todos os templates do banco de dados, ordenando-os pela data
      #    de criação em ordem decrescente. Retorna um JSON contendo apenas o `id`,
      #    `titulo` e `created_at` de cada template.
      # Argumentos: Nenhum.
      # Retorno:
      #    - `JSON`: Uma array de objetos JSON, onde cada objeto representa um template
      #      com `id`, `titulo` e `created_at`.
      # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados.
      #    - Comunicação via API: Envia uma resposta JSON ao cliente.
      # GET /api/v1/templates
      def index
        templates = Template.order(created_at: :desc)
        render json: templates.to_json(only: [ :id, :titulo, :created_at ])
      end

      ##
      # Exibe os detalhes de um template específico.
      #
      # Descrição: Encontra um template pelo seu ID e retorna seus detalhes,
      #    incluindo as questões associadas e suas opções formatadas.
      # Argumentos:
      #    - `params[:id]`: O ID do template a ser exibido.
      # Retorno:
      #    - `JSON`: Um objeto JSON contendo os detalhes do template e suas questões,
      #      com as opções de cada questão formatadas como um array.
      # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados.
      #    - Comunicação via API: Envia uma resposta JSON ao cliente.
      #    - Pode retornar um erro 404 se o template não for encontrado (tratado por `set_template`).
      # GET /api/v1/templates/:id
      def show
        render json: @template.to_json(include: { questoes: { methods: :opcoes_array } })
      end

      ##
      # Cria um novo template.
      #
      # Descrição: Recebe os parâmetros para a criação de um novo template,
      #    associa o template ao `current_usuario` como criador e tenta salvá-lo
      #    no banco de dados. Retorna uma resposta JSON indicando sucesso ou falha.
      # Argumentos:
      #    - `template_params`: Parâmetros permitidos para a criação do template,
      #      incluindo o `titulo` e atributos aninhados para `questoes`.
      # Retorno:
      #    - `JSON`: Retorna um JSON com `mensagem` e o objeto `template` criado,
      #      com status `:created` (201) em caso de sucesso.
      #    - `JSON`: Retorna um JSON com `erro` (mensagens de validação) e status
      #      `:unprocessable_entity` (422) em caso de falha no salvamento.
      # Efeitos colaterais:
      #    - Alterações no banco de dados: Cria um novo registro na tabela `templates`
      #      e, possivelmente, novos registros na tabela `questoes`.
      #    - Comunicação via API: Envia respostas JSON ao cliente.
      # POST /api/v1/templates
      def create
        @template = Template.new(template_params.merge(criador_id: current_usuario.id))
        if @template.save
          render json: { mensagem: "Template '#{@template.titulo}' salvo com sucesso", template: @template }, status: :created
        else
          render json: { erro: @template.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      ##
      # Atualiza um template existente.
      #
      # Descrição: Encontra um template pelo seu ID e tenta atualizá-lo com os
      #    parâmetros fornecidos. Retorna uma resposta JSON indicando sucesso ou falha.
      # Argumentos:
      #    - `params[:id]`: O ID do template a ser atualizado.
      #    - `template_params`: Parâmetros permitidos para atualização do template.
      # Retorno:
      #    - `JSON`: Retorna um JSON com `mensagem` e o objeto `template` atualizado,
      #      com status `:ok` (200) em caso de sucesso.
      #    - `JSON`: Retorna um JSON com `erro` (mensagens de validação) e status
      #      `:unprocessable_entity` (422) em caso de falha na atualização.
      # Efeitos colaterais:
      #    - Alterações no banco de dados: Atualiza um registro na tabela `templates`
      #      e pode criar, atualizar ou destruir registros na tabela `questoes`.
      #    - Comunicação via API: Envia respostas JSON ao cliente.
      # PATCH/PUT /api/v1/templates/:id
      def update
        if @template.update(template_params)
          render json: { mensagem: "Template '#{@template.titulo}' atualizado com sucesso", template: @template }, status: :ok
        else
          render json: { erro: @template.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      ##
      # Exclui um template existente.
      #
      # Descrição: Encontra um template pelo seu ID e tenta removê-lo do banco de dados.
      #    Inclui lógica para verificar se o template está sendo utilizado por formulários
      #    associados, impedindo a exclusão e retornando uma mensagem de erro amigável nesse caso.
      # Argumentos:
      #    - `params[:id]`: O ID do template a ser excluído.
      # Retorno:
      #    - `JSON`: Retorna um JSON com `mensagem` de sucesso e status `:ok` (200)
      #      se o template for excluído.
      #    - `JSON`: Retorna um JSON com `erro` e status `:unprocessable_entity` (422)
      #      se a exclusão falhar (ex: template em uso).
      # Efeitos colaterais:
      #    - Alterações no banco de dados: Exclui um registro da tabela `templates`
      #      e suas questões associadas se não houver formulários vinculados.
      #    - Comunicação via API: Envia respostas JSON ao cliente.
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
                            @template.errors.full_messages.join(", ")
                          end
          render json: { erro: error_message }, status: :unprocessable_entity
        end
      end
      # ===============================================================

      private

      ##
      # Define a variável de instância `@template` com base no ID dos parâmetros.
      #
      # Descrição: Método auxiliar usado como um `before_action` para buscar um `Template`
      #    específico pelo seu `id` e atribuí-lo a `@template`, evitando repetição de código.
      #    Se o template não for encontrado, retorna um erro JSON 404.
      # Argumentos:
      #    - `params[:id]`: O ID do template a ser encontrado.
      # Retorno: Atribui um objeto `Template` à variável de instância `@template`.
      # Efeitos colaterais:
      #    - Comunicação via API: Pode renderizar um JSON de erro com status `:not_found` (404)
      #      se o template não for encontrado.
      def set_template
        @template = Template.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Template não encontrado." }, status: :not_found
      end

      ##
      # Define os parâmetros permitidos para o objeto `Template`.
      #
      # Descrição: Método auxiliar que utiliza o `strong_parameters` do Rails para
      #    garantir que apenas o atributo `titulo` e os atributos aninhados de `questoes`
      #    (incluindo `id`, `tipo`, `enunciado`, `obrigatoria`, `opcoes` como array,
      #    e `_destroy`) possam ser atribuídos ao template, prevenindo ataques
      #    de atribuição em massa.
      # Argumentos: Nenhum.
      # Retorno: Um hash de parâmetros filtrados.
      # Efeitos colaterais: Nenhum.
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
