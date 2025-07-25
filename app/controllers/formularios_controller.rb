# Caminho: app/controllers/formularios_controller.rb
class FormulariosController < ApplicationController
  # Garante que o usuário esteja autenticado antes de qualquer ação.
  before_action :authenticate_usuario!
  # Define o formulário antes de certas ações para evitar duplicação de código.
  before_action :set_formulario, only: [ :show, :create_resposta ]

  ##
  # Lista os formulários pendentes para o aluno logado.
  #
  # Descrição: Esta ação busca e exibe todos os formulários que o `current_usuario`
  #    (assumindo que seja um aluno) ainda não respondeu e que estão associados
  #    às turmas em que ele está matriculado.
  # Argumentos: Nenhum.
  # Retorno: Atribui uma coleção de objetos `Formulario` à variável de instância `@formularios_pendentes`.
  #    Renderiza a template `index.html.erb`. Não retorna nenhum valor explícito.
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados ou redirecionamento direto.
  def index
    # Lista formulários pendentes para o aluno
    @formularios_pendentes = formularios_pendentes_para_aluno
  end

  ##
  # Exibe um formulário específico para que o usuário possa respondê-lo.
  #
  # Descrição: Encontra um formulário pelo seu ID, inicializa um novo objeto
  #    `RespostaFormulario` e busca as questões do template associado.
  #    Verifica se o usuário já respondeu a este formulário e, se sim,
  #    redireciona-o com uma mensagem de alerta.
  # Argumentos:
  #    - `params[:id]`: O ID do formulário a ser exibido.
  # Retorno:
  #    - Atribui um novo objeto `RespostaFormulario` a `@resposta` e uma coleção de `Questao` a `@questoes`.
  #    - Renderiza a template `show.html.erb`.
  #    - Redireciona para `formularios_path` com um `alert` se o formulário já foi respondido.
  # Efeitos colaterais:
  #    - Pode redirecionar a página.
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

  ##
  # Cria e persiste as respostas de um formulário enviado pelo usuário.
  #
  # Descrição: Recebe as respostas de um formulário, associa-as ao formulário
  #    e ao `current_usuario`. Realiza uma validação customizada para garantir
  #    que todas as questões obrigatórias foram respondidas. Se as validações
  #    passarem e o salvamento for bem-sucedido, cria as `RespostaQuestao`
  #    individuais. Redireciona com sucesso ou renderiza o formulário novamente com erros.
  # Argumentos:
  #    - `params[:id]`: O ID do formulário que está sendo respondido.
  #    - `params[:resposta_formulario]`: Hash de parâmetros contendo os dados
  #      da resposta do formulário, incluindo `respostas_questoes_attributes`.
  # Retorno:
  #    - Redireciona para `formularios_path` com um `notice` em caso de sucesso.
  #    - Renderiza a template `show.html.erb` com status `:unprocessable_entity`
  #      e mensagens de erro se as validações falharem ou o salvamento não for bem-sucedido.
  # Efeitos colaterais:
  #    - Alterações no banco de dados: Cria um novo registro em `RespostaFormulario`
  #      e múltiplos registros em `RespostaQuestao`.
  #    - Redirecionamento de página.
  #    - Exibição de mensagens flash (notice/alert).
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
  # Define os parâmetros permitidos para o objeto `RespostaFormulario`.
  #
  # Descrição: Método auxiliar que utiliza o `strong_parameters` do Rails para
  #    garantir que apenas os atributos `formulario_id` e os atributos aninhados
  #    de `respostas_questoes_attributes` (incluindo `questao_id`, `valor_resposta`,
  #    e `texto_resposta`) possam ser atribuídos à resposta do formulário,
  #    prevenindo ataques de atribuição em massa.
  # Argumentos: Nenhum.
  # Retorno: Um hash de parâmetros filtrados.
  # Efeitos colaterais: Nenhum.
  def resposta_params
    params.require(:resposta_formulario).permit(:formulario_id,
      respostas_questoes_attributes: [ :questao_id, :valor_resposta, :texto_resposta ])
  end

  ##
  # Busca os formulários pendentes para o aluno logado.
  #
  # Descrição: Identifica as turmas em que o `current_usuario` está matriculado,
  #    encontra todos os formulários associados a essas turmas e, em seguida,
  #    filtra aqueles que o aluno ainda não respondeu.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Formulario` que o aluno ainda precisa responder.
  # Efeitos colaterais: Nenhum.
  def formularios_pendentes_para_aluno
    # Busca formulários das turmas do aluno que ainda não foram respondidos
    turmas_do_aluno = current_usuario.turmas
    formularios_das_turmas = Formulario.joins(:turmas).where(turmas: { id: turmas_do_aluno.ids }).distinct

    # Remove os já respondidos pelo aluno
    respondidos = RespostaFormulario.where(respondente: current_usuario).pluck(:formulario_id)
    formularios_das_turmas.where.not(id: respondidos)
  end

  ##
  # Verifica se o usuário atual já respondeu ao formulário em questão.
  #
  # Descrição: Consulta o banco de dados para verificar a existência de um
  #    registro em `RespostaFormulario` que corresponda ao formulário atual
  #    (`@formulario`) e ao `current_usuario` como respondente.
  # Argumentos: Nenhum.
  # Retorno: `true` se o formulário já foi respondido pelo usuário, `false` caso contrário.
  # Efeitos colaterais: Nenhum.
  def ja_respondeu?
    RespostaFormulario.exists?(formulario: @formulario, respondente: current_usuario)
  end

  ##
  # Valida se todas as questões obrigatórias do formulário foram respondidas.
  #
  # Descrição: Itera sobre as questões obrigatórias do template do formulário
  #    e verifica se uma resposta correspondente (seja `valor_resposta` ou `texto_resposta`)
  #    foi fornecida nos parâmetros da requisição. Se alguma questão obrigatória
  #    não tiver uma resposta preenchida, adiciona um erro ao objeto `@resposta`
  #    e retorna `false`.
  # Argumentos: Nenhum.
  # Retorno: `true` se todas as questões obrigatórias foram respondidas, `false` caso contrário.
  # Efeitos colaterais: Adiciona erros ao objeto `@resposta` se a validação falhar.
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
