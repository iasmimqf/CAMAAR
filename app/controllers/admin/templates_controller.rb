# app/controllers/templates_controller.rb
class TemplatesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_template, only: %i[show edit update destroy]

  def index
    @templates = Template.all
  end

  def new
    @template = Template.new
    @template.questions.build # Build empty question
  end

  def create
    @template = Template.new(template_params)

    if @template.save
      redirect_to templates_path, notice: "Template '#{@template.title}' salvo com sucesso"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_template
    @template = Template.find(params[:id])
  end

  def template_params
    params.require(:template).permit(
      :title,
      questions_attributes: [
        :id,
        :question_type,
        :prompt,
        :mandatory,
        :options,
        :_destroy
      ]
    )
  end

end