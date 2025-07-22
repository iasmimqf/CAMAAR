# app/controllers/api/v1/formularios_controller.rb
class Api::V1::FormulariosController < Api::V1::BaseController
  # O `before_action :authenticate_usuario!` já é herdado do BaseController.

  # GET /api/v1/formularios
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
        nome: form.template.nome, 
        prazo: form.try(:prazo) ? form.prazo.strftime("%d/%m/%Y") : "Não definido", 
        disciplina: turma_principal&.disciplina&.nome || "Não definida",
        turma: turma_principal&.codigo_turma || "Não definida"
      }
    end

    render json: formularios_formatados
  end

  # GET /api/v1/formularios/:id
  def show
    formulario = Formulario.includes(template: { questoes: :opcoes }).find(params[:id])

    render json: {
      id: formulario.id,
      nome_template: formulario.template.nome,
      questoes: formulario.template.questoes.map do |questao|
        {
          id: questao.id,
          texto: questao.texto,
          tipo: questao.tipo_questao,
          opcoes: questao.opcoes.map do |opcao|
            {
              id: opcao.id,
              texto: opcao.texto
            }
          end
        }
      end
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Formulário não encontrado' }, status: :not_found
  end

  # ===============================================================
  # ▼▼▼ NOVO MÉTODO ADICIONADO ▼▼▼
  # ===============================================================
  # POST /api/v1/formularios/:id/responder
  def responder
    formulario = Formulario.find(params[:id])
    respostas_params = params.require(:respostas).permit! # Permite o hash de respostas

    # Usamos uma transação para garantir que todas as respostas sejam salvas
    # ou nenhuma delas, evitando dados inconsistentes.
    ActiveRecord::Base.transaction do
      # 1. Cria o registro principal que liga o usuário ao formulário respondido.
      resposta_formulario = RespostaFormulario.create!(
        formulario: formulario,
        respondente: current_usuario
      )

      # 2. Itera sobre cada resposta enviada pelo frontend.
      respostas_params.each do |questao_id, valor|
        questao = Questao.find(questao_id)
        
        # Cria a resposta individual.
        # Se for múltipla escolha, salva o ID da opção.
        # Se for texto, salva o texto.
        Resposta.create!(
          resposta_formulario: resposta_formulario,
          questao: questao,
          opcao_id: questao.tipo_questao == 'multipla_escolha' ? valor : nil,
          texto: questao.tipo_questao == 'texto_longo' ? valor : nil
        )
      end
    end

    render json: { message: 'Respostas salvas com sucesso!' }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "Erro ao salvar: #{e.message}" }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Formulário ou questão não encontrada' }, status: :not_found
  end
  # ===============================================================
end