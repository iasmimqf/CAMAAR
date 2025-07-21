class FormulariosController < ApplicationController
  before_action :authenticate_usuario!
  before_action :set_formulario, only: [ :show, :create_resposta ]

  def index
    # Lista formulários pendentes para o aluno
    @formularios_pendentes = formularios_pendentes_para_aluno
  end

  def show
    # Exibe o formulário para resposta
    @resposta = RespostaFormulario.new
    @questoes = @formulario.template.questoes.order(:id)

    # Verifica se já respondeu
    if ja_respondeu?
      redirect_to formularios_path, alert: "Você já respondeu este formulário"
      nil
    end
  end

  def create_resposta
    @resposta = RespostaFormulario.new
    @resposta.formulario = @formulario
    @resposta.respondente = current_usuario

    # Valida se todas as questões obrigatórias foram respondidas
    if valida_questoes_obrigatorias?
      if @resposta.save
        # Cria as respostas das questões após salvar o formulário
        if params[:resposta_formulario] && params[:resposta_formulario][:respostas_questoes_attributes]
          params[:resposta_formulario][:respostas_questoes_attributes].each do |index, resposta_attrs|
            if resposta_attrs[:questao_id].present? &&
               (resposta_attrs[:valor_resposta].present? || resposta_attrs[:texto_resposta].present?)

              @resposta.respostas_questoes.create!(
                questao_id: resposta_attrs[:questao_id],
                valor_resposta: resposta_attrs[:valor_resposta],
                texto_resposta: resposta_attrs[:texto_resposta]
              )
            end
          end
        end

        redirect_to formularios_path, notice: "Formulário enviado com sucesso!"
      else
        @questoes = @formulario.template.questoes.order(:id)
        # Preserva os valores enviados para reexibir no formulário
        @valores_enviados = params[:resposta_formulario][:respostas_questoes_attributes] if params[:resposta_formulario]
        render :show, status: :unprocessable_entity
      end
    else
      @questoes = @formulario.template.questoes.order(:id)
      # Preserva os valores enviados para reexibir no formulário
      @valores_enviados = params[:resposta_formulario][:respostas_questoes_attributes] if params[:resposta_formulario]
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_formulario
    @formulario = Formulario.find(params[:id])
  end

  def resposta_params
    params.require(:resposta_formulario).permit(:formulario_id,
      respostas_questoes_attributes: [ :questao_id, :valor_resposta, :texto_resposta ])
  end

  def formularios_pendentes_para_aluno
    # Busca formulários das turmas do aluno que ainda não foram respondidos
    turmas_do_aluno = current_usuario.turmas
    formularios_das_turmas = Formulario.joins(:turmas).where(turmas: { id: turmas_do_aluno.ids }).distinct

    # Remove os já respondidos pelo aluno
    respondidos = RespostaFormulario.where(respondente: current_usuario).pluck(:formulario_id)
    formularios_das_turmas.where.not(id: respondidos)
  end

  def ja_respondeu?
    RespostaFormulario.exists?(formulario: @formulario, respondente: current_usuario)
  end

  def valida_questoes_obrigatorias?
    return true unless params[:resposta_formulario] && params[:resposta_formulario][:respostas_questoes_attributes]

    questoes_obrigatorias = @formulario.template.questoes.where(obrigatoria: true)
    respostas = params[:resposta_formulario][:respostas_questoes_attributes]

    questoes_obrigatorias.each do |questao|
      resposta_encontrada = false

      respostas.each do |index, resposta_attrs|
        if resposta_attrs[:questao_id].to_i == questao.id
          case questao.tipo
          when "Escala"
            if resposta_attrs[:valor_resposta].present?
              resposta_encontrada = true
              break
            end
          when "Texto"
            if resposta_attrs[:texto_resposta].present?
              resposta_encontrada = true
              break
            end
          end
        end
      end

      unless resposta_encontrada
        @resposta.errors.add(:base, "Por favor, responda todas as questões obrigatórias")
        return false
      end
    end

    true
  end
end
