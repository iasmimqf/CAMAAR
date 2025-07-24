# app/controllers/api/v1/formularios_controller.rb
class Api::V1::FormulariosController < Api::V1::BaseController
  # ... (método index sem alterações) ...
  def index
    if current_usuario.admin?
      formularios = Formulario.includes(:template, turmas: :disciplina).order(created_at: :desc)
    else
      formularios = current_usuario.formularios_pendentes.includes(:template, turmas: :disciplina)
    end

    formularios_formatados = formularios.map do |form|
      turma_principal = form.turmas.first
      {
        id: form.id,
        nome: form.template.titulo,
        prazo: form.try(:prazo) ? form.prazo.strftime("%d/%m/%Y") : "Não definido",
        disciplina: turma_principal&.disciplina&.nome || "Não definida",
        turma: turma_principal&.codigo_turma || "Não definida"
      }
    end

    render json: formularios_formatados
  end

  # ===============================================================
  # ▼▼▼ MÉTODO SHOW CORRIGIDO ▼▼▼
  # ===============================================================
  # GET /api/v1/formularios/:id
  def show
    # 1. CORREÇÃO: Removemos `:opcoes` do includes, pois não é uma associação.
    formulario = Formulario.includes(template: :questoes).find(params[:id])

    render json: {
      id: formulario.id,
      nome_template: formulario.template.titulo,
      questoes: formulario.template.questoes.map do |questao|
        {
          id: questao.id,
          texto: questao.enunciado, # Usando 'enunciado' conforme o seu modelo
          tipo: questao.tipo,
          # 2. CORREÇÃO: Usamos o método `opcoes_array` para obter as opções
          #    e as formatamos como o frontend espera (um array de objetos).
          opcoes: questao.opcoes_array.map.with_index do |texto_opcao, index|
            {
              id: index, # Usamos o índice como um ID simples para o frontend
              texto: texto_opcao
            }
          end
        }
      end
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Formulário não encontrado" }, status: :not_found
  end
  # ===============================================================

  # ... (métodos responder, create e private sem alterações) ...
  def responder
    formulario = Formulario.find(params[:id])
    respostas_params = params.require(:respostas).permit!

    ActiveRecord::Base.transaction do
      resposta_formulario = RespostaFormulario.create!(
        formulario: formulario,
        respondente: current_usuario
      )

      respostas_params.each do |questao_id, valor|
        questao = Questao.find(questao_id)

        Resposta.create!(
          resposta_formulario: resposta_formulario,
          questao: questao,
          opcao_id: questao.tipo == "multipla_escolha" ? valor : nil,
          texto: questao.tipo == "texto_longo" ? valor : nil
        )
      end
    end

    render json: { message: "Respostas salvas com sucesso!" }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "Erro ao salvar: #{e.message}" }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Formulário ou questão não encontrada" }, status: :not_found
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
