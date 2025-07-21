class Admin::TemplatesController < ApplicationController
  before_action :authenticate_usuario!
  before_action :ensure_admin
  before_action :set_template, only: [ :show, :edit, :update, :destroy ]

  layout proc { Rails.env.test? ? "test" : "application" }

  def index
    @templates = Template.includes(:criador).order(:titulo)
  end

  def show
  end

  def new
    @template = Template.new
    # Não inicializa questões automaticamente
  end

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

  def edit
  end

  def update
    if @template.update(template_params)
      redirect_to admin_templates_path, notice: "O template foi atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

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

  def set_template
    @template = Template.find(params[:id])
  end

  def template_params
    params.require(:template).permit(:titulo, questoes_attributes: [ :id, :enunciado, :tipo, :opcoes, :obrigatoria, :_destroy ])
  end

  def ensure_admin
    redirect_to root_path, alert: "Acesso negado." unless current_usuario&.admin?
  end
end
