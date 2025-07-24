class Api::V1::FormulariosController < Api::V1::BaseController
  def index
    formularios = if current_usuario.admin?
      Formulario.includes(:template, turmas: :disciplina).order(created_at: :desc)
    else
      current_usuario.formularios_pendentes.includes(:template, turmas: :disciplina)
    end

    formularios_formatados = formularios.map do |form|
      turma_principal = form.turmas.first
      {
        id: form.id,
        nome: form.template.titulo,
        prazo: form.prazo&.strftime("%d/%m/%Y") || "Não definido",
        disciplina: turma_principal&.disciplina&.nome || "Não definida",
        turma: turma_principal&.codigo_turma || "Não definida"
      }
    end

    render json: formularios_formatados
  end

  def show
    formulario = Formulario.includes(template: :questoes).find(params[:id])

    if formulario.prazo.present? && formulario.prazo < Time.current
      return render json: { error: 'Este formulário já expirou e não pode mais ser respondido.' }, status: :forbidden
    end

    render json: {
      id: formulario.id,
      nome_template: formulario.template.titulo,
      questoes: formulario.template.questoes.map do |questao|
        {
          id: questao.id,
          texto: questao.enunciado,
          tipo: questao.tipo,
          opcoes: questao.opcoes_array.map.with_index do |texto_opcao, index|
            { id: index, texto: texto_opcao }
          end
        }
      end
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Formulário não encontrado" }, status: :not_found
  end

  def responder
    formulario = Formulario.find(params[:id])

    if formulario.prazo.present? && formulario.prazo < Time.current
      return render json: { error: 'Este formulário já expirou e não pode mais ser respondido.' }, status: :forbidden
    end

    respostas_params = params.require(:respostas).permit!.to_h

    resposta_formulario = nil
    ActiveRecord::Base.transaction do
      resposta_formulario = RespostaFormulario.find_or_create_by!(
        formulario: formulario,
        respondente: current_usuario
      )

      respostas_params.each do |questao_id, valor_recebido|
        questao = Questao.find(questao_id.to_i)

        attrs = {}

        Rails.logger.debug "DEBUG questao id=#{questao.id} tipo=#{questao.tipo} valor_recebido=#{valor_recebido.inspect}"

        case questao.tipo
        when 'Texto'
          texto = valor_recebido.to_s.strip
          attrs[:texto_resposta] = texto
          Rails.logger.debug "DEBUG Texto: #{texto.inspect}"

        when 'Escala'
          valor_array = if valor_recebido.is_a?(Array)
                          valor_recebido.map(&:to_i)
                        elsif valor_recebido.nil? || valor_recebido.to_s.strip.empty?
                          []
                        else
                          [valor_recebido.to_i]
                        end
          attrs[:valor_resposta] = valor_array
          Rails.logger.debug "DEBUG Escala valor_resposta: #{valor_array.inspect}"

        when 'Checkbox'
          valor_array = if valor_recebido.is_a?(Array)
                          valor_recebido.map(&:to_i)
                        else
                          []
                        end
          attrs[:valor_resposta] = valor_array
          Rails.logger.debug "DEBUG Checkbox valor_resposta: #{valor_array.inspect}"

        else
          raise "Tipo de questão não suportado: #{questao.tipo}"
        end

        resposta_questao = RespostaQuestao.find_or_initialize_by(
          resposta_formulario: resposta_formulario,
          questao: questao
        )

        resposta_questao.assign_attributes(attrs)

        Rails.logger.debug "DEBUG após assign_attributes valor_resposta: #{resposta_questao.valor_resposta.inspect}"
        Rails.logger.debug "DEBUG após assign_attributes texto_resposta: #{resposta_questao.texto_resposta.inspect}"

        unless resposta_questao.valid?
          Rails.logger.debug "DEBUG erros: #{resposta_questao.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid.new(resposta_questao)
        end

        resposta_questao.save!
      end
    end

    render json: { message: 'Formulário respondido com sucesso!', resposta_id: resposta_formulario.id }, status: :created

  rescue ActiveRecord::RecordInvalid => e
    error_message = e.record.errors.full_messages.join(', ')
    render json: { error: "Erro de validação: #{error_message}" }, status: :unprocessable_entity

  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Formulário ou questão não encontrado: #{e.message}" }, status: :not_found

  rescue StandardError => e
    render json: { error: "Erro inesperado: #{e.message}" }, status: :internal_server_error
  end

  def create
    formulario = Formulario.new(formulario_params)
    formulario.criador = current_usuario

    if formulario.save
      render json: { mensagem: "Formulário enviado com sucesso!" }, status: :created
    else
      render json: { erro: formulario.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def formulario_params
    params.require(:formulario).permit(:template_id, :prazo, turma_ids: [])
  end
end