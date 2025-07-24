# Caminho: app/controllers/admin/formularios_controller.rb
class Admin::FormulariosController < Admin::BaseController
  # O seu BaseController já deve ter o filtro de segurança para admin.
  
  # <<< ADICIONADO: Desativa a verificação de token CSRF apenas para a ação 'create',
  # pois ela será usada como um endpoint de API pelo React.
  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :set_formulario, only: [:show, :edit, :update, :destroy]

  def index
    @formularios = Formulario.includes(:template, :turmas, :criador).order(created_at: :desc)
  end

  def resultados
    @formularios = Formulario.includes(:template, :turmas, :criador).order(created_at: :desc)
  end

  def show
  end

  def new
    @formulario = Formulario.new
    @templates = Template.includes(:questoes).order(:titulo)
    @turmas = Turma.includes(:disciplina).order("disciplinas.nome, codigo_turma")
  end

  # <<< MÉTODO CREATE MODIFICADO PARA FUNCIONAR COMO API >>>
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

  def edit
    @templates = Template.includes(:questoes).order(:titulo)
    @turmas = Turma.includes(:disciplina).order("disciplinas.nome, codigo_turma")
  end

  def update
    if @formulario.update(formulario_params)
      redirect_to admin_formularios_path, notice: "Formulário atualizado com sucesso"
    else
      @templates = Template.includes(:questoes).order(:titulo)
      @turmas = Turma.includes(:disciplina).order("disciplinas.nome, codigo_turma")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @formulario.destroy
    redirect_to admin_formularios_path, notice: "Formulário excluído com sucesso"
  end

  private

  def set_formulario
    @formulario = Formulario.find(params[:id])
  end

  # Este método continua a ser usado pelas ações de HTML (update)
  def formulario_params
    params.require(:formulario).permit(:template_id, turma_ids: [])
  end

  # <<< MÉTODO DE VALIDAÇÃO REFINADO >>>
  # Foca apenas na regra de negócio que não está no modelo.
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
      nomes_turmas = turmas_ja_avaliadas.map(&:nome_completo).join(', ')
      @formulario.errors.add(:base, "As seguintes turmas já foram avaliadas neste semestre: #{nomes_turmas}")
      return false
    end

    true
  end
  
  # O seu método ensure_admin foi removido daqui pois a lógica já deve estar no Admin::BaseController
end
