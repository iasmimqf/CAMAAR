# Caminho: app/controllers/admin/formularios_controller.rb
class Admin::FormulariosController < Admin::BaseController
  # O seu BaseController já deve ter o filtro de segurança para admin.

  # Desativa a verificação de token CSRF apenas para a ação 'create',
  # pois ela será usada como um endpoint de API pelo React.
  skip_before_action :verify_authenticity_token, only: [ :create ]

  # Define o formulário antes de certas ações para evitar duplicação de código.
  before_action :set_formulario, only: [:show, :edit, :update, :destroy]

  ##
  # Exibe uma lista de todos os formulários existentes.
  #
  # Descrição: Busca todos os formulários do banco de dados, incluindo suas
  #    associações (template, turmas, criador) para otimização de consultas,
  #    e os ordena pela data de criação em ordem decrescente.
  # Argumentos: Nenhum.
  # Retorno: Atribui uma coleção de objetos `Formulario` à variável de instância `@formularios`.
  #    Renderiza a template `index.html.erb`. Não retorna nenhum valor explícito.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def index
    @formularios = Formulario.includes(:template, :turmas, :criador).order(created_at: :desc)
  end

  ##
  # Exibe uma lista de formulários para visualização de resultados.
  #
  # Descrição: Similar à ação `index`, busca e lista os formulários, mas com
  #    o propósito de apresentar uma visão geral para acesso aos resultados.
  # Argumentos: Nenhum.
  # Retorno: Atribui uma coleção de objetos `Formulario` à variável de instância `@formularios`.
  #    Renderiza a template `resultados.html.erb`. Não retorna nenhum valor explícito.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def resultados
    @formularios = Formulario.includes(:template, :turmas, :criador).order(created_at: :desc)
  end

  ##
  # Exibe os detalhes de um formulário específico.
  #
  # Descrição: Encontra um formulário pelo seu ID e o prepara para ser exibido.
  # Argumentos:
  #    - `params[:id]`: O ID do formulário a ser exibido.
  # Retorno: Atribui um objeto `Formulario` à variável de instância `@formulario`.
  #    Renderiza a template `show.html.erb`. Não retorna nenhum valor explícito.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def show
  end

  ##
  # Prepara um novo formulário para criação.
  #
  # Descrição: Instancia um novo objeto `Formulario` e busca as `Templates` e `Turmas`
  #    necessárias para preencher os campos do formulário na view.
  # Argumentos: Nenhum.
  # Retorno: Atribui um novo objeto `Formulario` a `@formulario`, uma coleção de `Template` a `@templates`
  #    e uma coleção de `Turma` a `@turmas`. Renderiza a template `new.html.erb`.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def new
    @formulario = Formulario.new
    @templates = Template.includes(:questoes).order(:titulo)
    @turmas = Turma.includes(:disciplina).order("disciplinas.nome, codigo_turma")
  end

  ##
  # Cria um novo formulário a partir dos dados recebidos via API.
  #
  # Descrição: Recebe os parâmetros de `template_id` e `turma_ids` de uma requisição
  #    JSON (geralmente de um frontend React), associa o formulário ao usuário criador
  #    (current_usuario), valida os dados, incluindo uma regra de negócio personalizada
  #    para turmas já avaliadas, e tenta salvar o formulário no banco de dados.
  # Argumentos:
  #    - `params`: Hash de parâmetros da requisição. Espera-se `params[:template_id]`
  #      e `params[:turma_ids]`.
  # Retorno:
  #    - `JSON`: Retorna um JSON com `mensagem: "Formulário criado com sucesso"` e status `:created` (201)
  #      em caso de sucesso.
  #    - `JSON`: Retorna um JSON com `erro: <mensagens de erro>` e status `:unprocessable_entity` (422)
  #      em caso de falha na validação ou salvamento.
  # Efeitos colaterais:
  #    - Alterações no banco de dados: Cria um novo registro na tabela `formularios`.
  #    - Comunicação via API: Envia respostas JSON ao cliente.
  def create
    # Os parâmetros agora vêm do frontend em React
    @formulario = Formulario.new(
      template_id: params[:template_id],
      turma_ids: params[:turma_ids]
    )
    @formulario.criador = current_usuario

    # Executa as validações e tenta salvar
    if @formulario.valid? && validate_turmas_nao_avaliadas && @formulario.save
      render json: { mensagem: "Formulário criado com sucesso" }, status: :created
    else
      # Se houver erros, junta todas as mensagens e devolve como JSON
      render json: { erro: @formulario.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  ##
  # Prepara um formulário existente para edição.
  #
  # Descrição: Encontra um formulário pelo seu ID e busca as `Templates` e `Turmas`
  #    necessárias para preencher os campos do formulário de edição na view.
  # Argumentos:
  #    - `params[:id]`: O ID do formulário a ser editado.
  # Retorno: Atribui um objeto `Formulario` a `@formulario`, uma coleção de `Template` a `@templates`
  #    e uma coleção de `Turma` a `@turmas`. Renderiza a template `edit.html.erb`.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def edit
    @templates = Template.includes(:questoes).order(:titulo)
    @turmas = Turma.includes(:disciplina).order("disciplinas.nome, codigo_turma")
  end

  ##
  # Atualiza um formulário existente com os dados enviados.
  #
  # Descrição: Encontra um formulário pelo seu ID e tenta atualizá-lo com os
  #    parâmetros permitidos. Redireciona com uma mensagem de sucesso em caso
  #    de êxito ou renderiza a página de edição novamente com erros em caso de falha.
  # Argumentos:
  #    - `params[:id]`: O ID do formulário a ser atualizado.
  #    - `formulario_params`: Parâmetros permitidos para atualização do formulário.
  # Retorno:
  #    - Redireciona para `admin_formularios_path` com uma mensagem de `notice`
  #      em caso de atualização bem-sucedida.
  #    - Renderiza a template `edit.html.erb` novamente com status `:unprocessable_entity`
  #      se a atualização falhar, exibindo os erros de validação.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Pode redirecionar para `admin_formularios_path`.
  #    - Alterações no banco de dados: Atualiza um registro na tabela `formularios`.
  #    - Exibição de mensagens flash (notice/erros de validação).
  def update
    if @formulario.update(formulario_params)
      redirect_to admin_formularios_path, notice: "Formulário atualizado com sucesso"
    else
      @templates = Template.includes(:questoes).order(:titulo)
      @turmas = Turma.includes(:disciplina).order("disciplinas.nome, codigo_turma")
      render :edit, status: :unprocessable_entity
    end
  end

  ##
  # Exclui um formulário existente.
  #
  # Descrição: Encontra um formulário pelo seu ID e o remove do banco de dados.
  # Argumentos:
  #    - `params[:id]`: O ID do formulário a ser excluído.
  # Retorno: Redireciona para `admin_formularios_path` com uma mensagem de `notice`.
  # Efeitos colaterais:
  #    - Redirecionamento de página: Redireciona para `admin_formularios_path`.
  #    - Alterações no banco de dados: Exclui um registro da tabela `formularios`.
  #    - Exibição de mensagens flash (notice).
  def destroy
    @formulario.destroy
    redirect_to admin_formularios_path, notice: "Formulário excluído com sucesso"
  end

  private

  ##
  # Define a variável de instância `@formulario` com base no ID dos parâmetros.
  #
  # Descrição: Método auxiliar usado como um `before_action` para buscar um `Formulario`
  #    específico pelo seu `id` e atribuí-lo a `@formulario`, evitando repetição de código.
  # Argumentos:
  #    - `params[:id]`: O ID do formulário a ser encontrado.
  # Retorno: Atribui um objeto `Formulario` à variável de instância `@formulario`.
  # Efeitos colaterais: Pode levantar uma exceção `ActiveRecord::RecordNotFound` se o ID não for encontrado.
  def set_formulario
    @formulario = Formulario.find(params[:id])
  end

  ##
  # Define os parâmetros permitidos para o objeto `Formulario`.
  #
  # Descrição: Método auxiliar que utiliza o `strong_parameters` do Rails para
  #    garantir que apenas os atributos `template_id` e `turma_ids` (como um array)
  #    possam ser atribuídos ao formulário, prevenindo ataques de atribuição em massa.
  # Argumentos: Nenhum.
  # Retorno: Um hash de parâmetros filtrados.
  # Efeitos colaterais: Nenhum.
  def formulario_params
    params.require(:formulario).permit(:template_id, turma_ids: [])
  end

  ##
  # Valida se as turmas selecionadas já foram avaliadas no semestre atual.
  #
  # Descrição: Este método de validação de regra de negócio personalizada verifica
  #    se alguma das turmas selecionadas para o formulário já possui um formulário
  #    associado criado no ano corrente. Se sim, adiciona um erro ao formulário.
  #    A lógica de "semestre atual" é simplificada para "ano atual" neste exemplo.
  # Argumentos: Nenhum.
  # Retorno:
  #    - `true`: Se não houver turmas selecionadas ou se nenhuma das turmas selecionadas
  #      já tiver sido avaliada neste ano.
  #    - `false`: Se alguma das turmas selecionadas já tiver sido avaliada neste ano,
  #      e adiciona uma mensagem de erro ao `@formulario.errors`.
  # Efeitos colaterais:
  #    - Modifica o objeto `@formulario` adicionando erros se a validação falhar.
  def validate_turmas_nao_avaliadas
    # A verificação só é necessária se houver turmas selecionadas.
    # As validações de presença de template e turmas já são tratadas pelo `@formulario.valid?`
    return true if @formulario.turma_ids.empty?

    # Verifica se alguma das turmas selecionadas já tem um formulário neste semestre.
    # NOTA: A lógica de "semestre atual" pode precisar de ser ajustada.
    # Aqui, consideramos o ano atual para simplificar.
    turmas_ja_avaliadas = Turma.joins(:formularios)
                               .where(id: @formulario.turma_ids)
                               .where(formularios: { created_at: Date.current.all_year })
                               .distinct

    if turmas_ja_avaliadas.any?
      nomes_turmas = turmas_ja_avaliadas.map(&:nome_completo).join(", ")
      @formulario.errors.add(:base, "As seguintes turmas já foram avaliadas neste semestre: #{nomes_turmas}")
      return false
    end

    true
  end

  # O seu método ensure_admin foi removido daqui pois a lógica já deve estar no Admin::BaseController
end
