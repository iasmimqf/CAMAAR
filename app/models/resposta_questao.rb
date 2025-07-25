# Caminho: app/models/resposta_questao.rb

##
# Representa a resposta de um usuário a uma questão específica dentro de um formulário.
#
# Descrição: Este modelo armazena as respostas individuais de um respondente para cada questão
#    de um formulário. Ele se associa a `RespostaFormulario` (a resposta geral do formulário)
#    e a `Questao` (a questão à qual esta resposta se refere). Inclui validações para
#    garantir a integridade dos dados e a adequação da resposta ao tipo da questão.
class RespostaQuestao < ApplicationRecord
  self.table_name = "resposta_questoes"

  ##
  # Associação: Pertence a um `RespostaFormulario`.
  #
  # Descrição: Define a relação onde cada `RespostaQuestao` está vinculada a uma
  #    instância de `RespostaFormulario`, que representa o conjunto completo de
  #    respostas de um usuário para um formulário específico.
  # Argumentos: Nenhum.
  # Retorno: O objeto `RespostaFormulario` ao qual esta resposta de questão pertence.
  # Efeitos colaterais: Define um método `resposta_formulario` e `resposta_formulario=`
  #    para gerenciar a associação.
  belongs_to :resposta_formulario

  ##
  # Associação: Pertence a uma `Questao`.
  #
  # Descrição: Define a relação onde cada `RespostaQuestao` está vinculada a uma
  #    instância de `Questao`, representando a pergunta à qual esta resposta se refere.
  # Argumentos: Nenhum.
  # Retorno: O objeto `Questao` ao qual esta resposta de questão pertence.
  # Efeitos colaterais: Define um método `questao` e `questao=` para gerenciar a associação.
  belongs_to :questao

  ##
  # Validação: Garante a presença do `questao_id`.
  #
  # Descrição: Assegura que um `questao_id` seja fornecido ao criar ou atualizar uma
  #    `RespostaQuestao`, garantindo que a resposta esteja sempre associada a uma questão.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `questao_id` estiver ausente.
  validates :questao_id, presence: true

  ##
  # Validação: Garante a presença do `resposta_formulario_id`.
  #
  # Descrição: Assegura que um `resposta_formulario_id` seja fornecido ao criar ou
  #    atualizar uma `RespostaQuestao`, garantindo que a resposta esteja sempre associada
  #    a um formulário respondido.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `resposta_formulario_id` estiver ausente.
  validates :resposta_formulario_id, presence: true

  ##
  # Validação: Garante a unicidade da combinação `questao_id` e `resposta_formulario_id`.
  #
  # Descrição: Impede que um mesmo usuário responda à mesma questão em um mesmo formulário
  #    múltiplas vezes, garantindo que cada questão tenha apenas uma resposta por formulário respondido.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se a combinação não for única.
  validates :questao_id, uniqueness: { scope: :resposta_formulario_id }

  ##
  # Serialização: Converte o atributo `valor_resposta` para e de JSON.
  #
  # Descrição: Permite que o atributo `valor_resposta` (que pode ser um Array de inteiros)
  #    seja armazenado como uma string JSON no banco de dados e automaticamente convertido
  #    de volta para um objeto Ruby (Array) ao ser lido.
  # Argumentos: Nenhum.
  # Retorno: O valor serializado/desserializado.
  # Efeitos colaterais: Altera o formato de armazenamento e recuperação do atributo `valor_resposta`.
  serialize :valor_resposta, JSON

  ##
  # Validação customizada: Garante que a resposta fornecida é adequada ao tipo da questão.
  #
  # Descrição: Este é um método de validação customizado que é executado para verificar
  #    a conformidade da `valor_resposta` ou `texto_resposta` com o `tipo` da `questao`
  #    associada. Ele garante que, por exemplo, uma resposta de escala seja um número
  #    dentro do range esperado, um checkbox seja um array de opções válidas, e um texto
  #    obrigatório não esteja em branco.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona erros ao objeto `RespostaQuestao` se a resposta não for adequada.
  validate :resposta_adequada_ao_tipo

  private

  ##
  # Método privado de validação: Verifica se a resposta é adequada ao tipo da questão.
  #
  # Descrição: Implementa a lógica de validação específica para cada tipo de questão:
  #    - **Segurança**: Verifica se a questão está associada corretamente.
  #    - **Escala**: Valida se `valor_resposta` está presente e se o valor numérico
  #      está dentro do range de 1 a 5.
  #    - **Texto**: Valida se `texto_resposta` não está em branco caso a questão seja obrigatória.
  #    - **Checkbox**: Valida se `valor_resposta` é um array, se não está vazio caso a questão
  #      seja obrigatória, e se todas as opções selecionadas são inteiros dentro do range
  #      de índices de opções da questão.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito. Adiciona erros ao objeto `errors` se a validação falhar.
  # Efeitos colaterais: Modifica o objeto `errors` da `RespostaQuestao`.
  def resposta_adequada_ao_tipo
    # Segurança: Se não tiver questao carregada, já retorna erro.
    if questao.nil?
      errors.add(:base, "Questão não está associada corretamente.")
      return
    end

    # Garante que valor_resposta não seja nil para facilitar validação
    resposta_valor = valor_resposta || (questao.tipo == 'Texto' ? nil : [])

    case questao.tipo
    when "Escala"
      if valor_resposta.blank?
        errors.add(:valor_resposta, "é obrigatório para questões de escala")
      elsif !valor_resposta.between?(1, 5)
        errors.add(:valor_resposta, "deve estar entre 1 e 5")
      end
    when "Texto"
      if questao.obrigatoria && texto_resposta.blank?
        errors.add(:base, "A resposta para a questão '#{questao.enunciado}' é obrigatória.")
      end
      # Não valida valor_resposta nesse caso, pois não usado.

    when 'Checkbox'
      unless resposta_valor.is_a?(Array)
        errors.add(:base, "A resposta para a questão '#{questao.enunciado}' deve ser uma lista de opções.")
        return
      end

      if questao.obrigatoria && resposta_valor.empty?
        errors.add(:base, "É necessário selecionar ao menos uma opção para a questão '#{questao.enunciado}'.")
        return
      end

      max_opcao_index = questao.opcoes_array.size - 1
      resposta_valor.each do |opcao_selecionada|
        unless opcao_selecionada.is_a?(Integer) && opcao_selecionada.between?(0, max_opcao_index)
          errors.add(:base, "A opção selecionada não é válida para a questão '#{questao.enunciado}'.")
        end
      end

    else
      errors.add(:base, "Tipo de questão desconhecido: #{questao.tipo}")
    end
  end
end
