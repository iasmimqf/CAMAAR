class Admin::FormulariosController < ApplicationController
  before_action :ensure_admin
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
    @turmas = Turma.includes(:disciplina).order('disciplinas.nome, codigo_turma')
  end

  def create
    @formulario = Formulario.new(formulario_params)
    @formulario.criador = current_usuario

    if validate_formulario_creation && @formulario.save
      redirect_to admin_formularios_path, notice: "Formulário criado com sucesso"
    else
      @templates = Template.includes(:questoes).order(:titulo)
      @turmas = Turma.includes(:disciplina).order('disciplinas.nome, codigo_turma')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @templates = Template.includes(:questoes).order(:titulo)
    @turmas = Turma.includes(:disciplina).order('disciplinas.nome, codigo_turma')
  end

  def update
    if @formulario.update(formulario_params)
      redirect_to admin_formularios_path, notice: "Formulário atualizado com sucesso"
    else
      @templates = Template.includes(:questoes).order(:titulo)
      @turmas = Turma.includes(:disciplina).order('disciplinas.nome, codigo_turma')
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

  def formulario_params
    params.require(:formulario).permit(:template_id, turma_ids: [])
  end

  def validate_formulario_creation
    errors = []

    # Verifica se template foi selecionado
    if formulario_params[:template_id].blank?
      errors << "Você deve selecionar um template"
    end

    # Verifica se pelo menos uma turma foi selecionada
    if formulario_params[:turma_ids].blank? || formulario_params[:turma_ids].reject(&:blank?).empty?
      errors << "Você deve selecionar ao menos uma turma"
    end

    # Verifica se alguma turma já foi avaliada neste semestre
    if formulario_params[:turma_ids].present?
      turmas_selecionadas = Turma.where(id: formulario_params[:turma_ids].reject(&:blank?))
      turmas_ja_avaliadas = turmas_selecionadas.joins(:formularios)
                                              .where(formularios: { created_at: Date.current.beginning_of_year..Date.current.end_of_year })
                                              .distinct

      if turmas_ja_avaliadas.any?
        errors << "Esta turma já foi avaliada no semestre atual"
      end
    end

    if errors.any?
      errors.each { |error| @formulario.errors.add(:base, error) }
      return false
    end

    true
  end

  def ensure_admin
    redirect_to root_path unless current_usuario&.admin?
  end
end
