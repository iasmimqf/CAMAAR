# Caminho: app/controllers/admin/templates_controller.rb
class Admin::TemplatesController < ApplicationController
  # Garante que o usuário esteja autenticado antes de qualquer ação.
  before_action :authenticate_usuario!
  # Garante que o usuário autenticado tenha privilégios de administrador.
  before_action :ensure_admin
  # Define o template antes de certas ações para evitar duplicação de código.
  before_action :set_template, only: [ :show, :edit, :update, :destroy ]

  # Define o layout a ser usado, com um layout específico para ambiente de teste.
  layout proc { Rails.env.test? ? "test" : "application" }

  ##
  # Exibe uma lista de todos os templates existentes.
  #
  # Descrição: Busca todos os templates do banco de dados, incluindo seu criador
  #    para otimização de consultas, e os ordena pelo título.
  # Argumentos: Nenhum.
  # Retorno: Atribui uma coleção de objetos `Template` à variável de instância `@templates`.
  #    Renderiza a template `index.html.erb`. Não retorna nenhum valor explícito.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def index
    @templates = Template.includes(:criador).order(:titulo)
  end

  ##
  # Exibe os detalhes de um template específico.
  #
  # Descrição: Encontra um template pelo seu ID e o prepara para ser exibido.
  # Argumentos:
  #    - `params[:id]`: O ID do template a ser exibido.
  # Retorno: Atribui um objeto `Template` à variável de instância `@template`.
  #    Renderiza a template `show.html.erb`. Não retorna nenhum valor explícito.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def show
  end

  ##
  # Prepara um novo template para criação.
  #
  # Descrição: Instancia um novo objeto `Template`. As questões associadas
  #    não são inicializadas automaticamente neste ponto.
  # Argumentos: Nenhum.
  # Retorno: Atribui um novo objeto `Template` a `@template`. Renderiza a template `new.html.erb`.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def new
    @template = Template.new
    # Não inicializa questões automaticamente
  end

  ##
  # Cria um novo template a partir dos dados enviados pelo formulário.
  #
  # Descrição: Recebe os parâmetros do formulário, instancia um novo `Template`,
  #    associa o template ao usuário criador (`current_usuario`) e tenta salvá-lo
  #    no banco de dados. Em caso de sucesso, redireciona; em caso de falha,
  #    renderiza o formulário novamente com os erros.
  # Argumentos:
  #    - `template_params`: Parâmetros permitidos para a criação do template,
  #      incluindo atributos aninhados para questões.
  # Retorno:
  #    - Redireciona para `admin_templates_path` com uma mensagem de `notice`
  #      em caso de criação bem-sucedida.
  #    - Renderiza a template `new.html.erb` novamente com status `:unprocessable_entity`
  #      se o salvamento falhar, exibindo os erros de validação.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Pode redirecionar para `admin_templates_path`.
  #    - Alterações no banco de dados: Cria um novo registro na tabela `templates`
  #      e, possivelmente, novos registros na tabela `questoes`.
  #    - Exibição de mensagens flash (notice/erros de validação).
  def create
    @template = Template.new(template_params)
    @template.criador = current_usuario

    if @template.save
      redirect_to admin_templates_path, notice: "Template '#{@template.titulo}' salvo com sucesso"
    else
      # Se não salvou, precisamos recriar as questões para o formulário
      @template.questoes.build if @template.questoes.empty?
      render :new, status: :unprocessable_entity
    end
  end

  ##
  # Prepara um template existente para edição.
  #
  # Descrição: Encontra um template pelo seu ID e o prepara para ser editado.
  # Argumentos:
  #    - `params[:id]`: O ID do template a ser editado.
  # Retorno: Atribui um objeto `Template` à variável de instância `@template`.
  #    Renderiza a template `edit.html.erb`. Não retorna nenhum valor explícito.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def edit
  end

  ##
  # Atualiza um template existente com os dados enviados.
  #
  # Descrição: Encontra um template pelo seu ID e tenta atualizá-lo com os
  #    parâmetros permitidos. Redireciona com uma mensagem de sucesso em caso
  #    de êxito ou renderiza a página de edição novamente com erros em caso de falha.
  # Argumentos:
  #    - `params[:id]`: O ID do template a ser atualizado.
  #    - `template_params`: Parâmetros permitidos para atualização do template.
  # Retorno:
  #    - Redireciona para `admin_templates_path` com uma mensagem de `notice`
  #      em caso de atualização bem-sucedida.
  #    - Renderiza a template `edit.html.erb` novamente com status `:unprocessable_entity`
  #      se a atualização falhar, exibindo os erros de validação.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Pode redirecionar para `admin_templates_path`.
  #    - Alterações no banco de dados: Atualiza um registro na tabela `templates`
  #      e pode criar, atualizar ou destruir registros na tabela `questoes`.
  #    - Exibição de mensagens flash (notice/erros de validação).
  def update
    if @template.update(template_params)
      redirect_to admin_templates_path, notice: "O template foi atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  ##
  # Exclui um template existente.
  #
  # Descrição: Encontra um template pelo seu ID e tenta removê-lo do banco de dados.
  #    Antes de excluir, verifica se há formulários associados a este template.
  #    Se houver, impede a exclusão e exibe um alerta.
  # Argumentos:
  #    - `params[:id]`: O ID do template a ser excluído.
  # Retorno: Redireciona para `admin_templates_path` com uma mensagem de `notice` ou `alert`.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Redireciona para `admin_templates_path`.
  #    - Alterações no banco de dados: Exclui um registro da tabela `templates`
  #      e seus `questoes` associados se não houver `formularios` vinculados.
  #    - Exibição de mensagens flash (notice/alert).
  def destroy
    # Verifica se há formulários usando este template
    if @template.formularios.any?
      redirect_to admin_templates_path, alert: "Não é possível excluir o template pois existem formulários associados a ele."
    else
      @template.destroy
      redirect_to admin_templates_path, notice: "O template foi excluído com sucesso."
    end
  end

  private

  ##
  # Define a variável de instância `@template` com base no ID dos parâmetros.
  #
  # Descrição: Método auxiliar usado como um `before_action` para buscar um `Template`
  #    específico pelo seu `id` e atribuí-lo a `@template`, evitando repetição de código.
  # Argumentos:
  #    - `params[:id]`: O ID do template a ser encontrado.
  # Retorno: Atribui um objeto `Template` à variável de instância `@template`.
  # Efeitos colaterais: Pode levantar uma exceção `ActiveRecord::RecordNotFound` se o ID não for encontrado.
  def set_template
    @template = Template.find(params[:id])
  end

  ##
  # Define os parâmetros permitidos para o objeto `Template`.
  #
  # Descrição: Método auxiliar que utiliza o `strong_parameters` do Rails para
  #    garantir que apenas os atributos `titulo` e os atributos aninhados de `questoes`
  #    (incluindo `id`, `enunciado`, `tipo`, `opcoes`, `obrigatoria`, e `_destroy`)
  #    possam ser atribuídos ao template, prevenindo ataques de atribuição em massa.
  # Argumentos: Nenhum.
  # Retorno: Um hash de parâmetros filtrados.
  # Efeitos colaterais: Nenhum.
  def template_params
    params.require(:template).permit(:titulo, questoes_attributes: [ :id, :enunciado, :tipo, :opcoes, :obrigatoria, :_destroy ])
  end

  ##
  # Garante que o usuário atual tem privilégios de administrador.
  #
  # Descrição: Método auxiliar usado como um `before_action` para verificar
  #    se o `current_usuario` existe e se ele possui o papel de administrador (`admin?`).
  #    Se não for um administrador, o usuário é redirecionado para a página inicial.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Redireciona para `root_path` se o usuário não for admin.
  #    - Exibição de mensagens flash: Define `flash[:alert]` com uma mensagem de acesso negado.
  def ensure_admin
    redirect_to root_path, alert: "Acesso negado." unless current_usuario&.admin?
  end
end
