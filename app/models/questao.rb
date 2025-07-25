# Caminho: app/models/questao.rb

##
# Representa uma questão de um template de formulário.
#
# Descrição: Este modelo define as características de uma questão, como seu
#    enunciado, tipo (Escala, Texto, Checkbox), se é obrigatória, e as opções
#    disponíveis para questões de múltipla escolha ou escala.
class Questao < ApplicationRecord
  self.table_name = "questoes"

  # --- Associações ---
  ##
  # Associação: Pertence a um `Template`.
  #
  # Descrição: Define a relação onde cada `Questao` está vinculada a um
  #    `Template` específico, do qual faz parte.
  # Argumentos: Nenhum.
  # Retorno: O objeto `Template` ao qual esta questão pertence.
  # Efeitos colaterais: Define um método `template` e `template=` para gerenciar a associação.
  belongs_to :template

  ##
  # Associação: Possui muitas `RespostaQuestoes`.
  #
  # Descrição: Define a relação onde uma `Questao` pode ter múltiplas
  #    `RespostaQuestoes` associadas a ela, representando as respostas
  #    individuais dos usuários a esta questão. Quando uma questão é destruída,
  #    todas as suas respostas associadas também são destruídas (`dependent: :destroy`).
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `RespostaQuestao` associados a esta questão.
  # Efeitos colaterais: Ao destruir uma `Questao`, suas `RespostaQuestoes` dependentes também são destruídas.
  has_many :resposta_questoes, class_name: "RespostaQuestao", dependent: :destroy

  # --- Validações ---
  ##
  # Validação: Garante a presença do `enunciado`.
  #
  # Descrição: Assegura que cada questão tenha um enunciado preenchido,
  #    que é o texto da pergunta.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `enunciado` estiver ausente.
  validates :enunciado, presence: { message: "O enunciado é obrigatório" }

  ##
  # Validação: Garante a presença e o tipo válido da questão.
  #
  # Descrição: Assegura que cada questão tenha um `tipo` definido e que este
  #    tipo seja um dos valores permitidos: "Escala", "Texto" ou "Checkbox".
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `tipo` estiver ausente ou for inválido.
  validates :tipo, presence: true, inclusion: { in: %w[Escala Texto Checkbox], message: "%{value} não é um tipo de questão válido" }

  ##
  # Validação: Garante que o atributo `obrigatoria` seja um booleano.
  #
  # Descrição: Assegura que o status `obrigatoria` da questão seja um valor
  #    booleano (`true` ou `false`), indicando se a questão exige uma resposta.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `obrigatoria` não for `true` ou `false`.
  validates :obrigatoria, inclusion: { in: [true, false] }

  # --- Métodos para lidar com o campo 'opcoes' ---

  ##
  # Define as opções da questão.
  #
  # Descrição: Sobrescreve o setter padrão para o atributo `opcoes`.
  #    Se o valor recebido for um Array, ele é convertido para uma string
  #    separada por vírgulas antes de ser salvo no banco de dados. Caso contrário,
  #    o valor é salvo diretamente.
  # Argumentos:
  #    - `value`: O valor a ser atribuído a `opcoes`, que pode ser uma String ou um Array.
  # Retorno: O valor processado para ser salvo.
  # Efeitos colaterais: Modifica o formato de armazenamento do atributo `opcoes`.
  def opcoes=(value)
    if value.is_a?(Array)
      super(value.join(','))
    else
      super(value)
    end
  end

  ##
  # Retorna as opções da questão como um array de strings.
  #
  # Descrição: Converte a string de `opcoes` (separada por vírgulas) em um
  #    Array de strings, removendo espaços em branco extras de cada opção.
  #    Retorna um array vazio se `opcoes` estiver em branco.
  # Argumentos: Nenhum.
  # Retorno: Um `Array` de strings, onde cada string é uma opção.
  # Efeitos colaterais: Nenhum.
  def opcoes_array
    return [] if opcoes.blank?
    opcoes.split(",").map(&:strip)
  end

  ##
  # Define as opções da questão a partir de um array.
  #
  # Descrição: Permite definir o atributo `opcoes` passando um Array de strings.
  #    O array é unido em uma única string separada por vírgulas antes de ser
  #    atribuído ao atributo `opcoes`.
  # Argumentos:
  #    - `array`: Um `Array` de strings que representam as opções.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Modifica o atributo `opcoes` do objeto.
  def opcoes_array=(array)
    self.opcoes = array.join(",") if array.present?
  end
end
