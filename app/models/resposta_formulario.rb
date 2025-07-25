# Caminho: app/models/resposta_formulario.rb

##
# Representa a resposta completa de um usuário a um formulário específico.
#
# Descrição: Este modelo agrupa todas as respostas individuais de um respondente
#    para um dado formulário. Ele se associa ao `Formulario` que foi respondido
#    e ao `Usuario` que o respondeu. Contém validações para garantir que um
#    usuário não responda ao mesmo formulário múltiplas vezes.
class RespostaFormulario < ApplicationRecord
  ##
  # Associação: Pertence a um `Formulario`.
  #
  # Descrição: Define a relação onde cada `RespostaFormulario` está vinculada
  #    a uma instância de `Formulario`, indicando qual formulário foi respondido.
  # Argumentos: Nenhum.
  # Retorno: O objeto `Formulario` ao qual esta resposta pertence.
  # Efeitos colaterais: Define um método `formulario` e `formulario=` para gerenciar a associação.
  belongs_to :formulario

  ##
  # Associação: Pertence a um `Respondente` (Usuário).
  #
  # Descrição: Define a relação onde cada `RespostaFormulario` tem um `Usuario`
  #    que o respondeu. O `class_name` é especificado como "Usuario" porque
  #    o nome da associação (`respondente`) difere do nome da classe (`Usuario`).
  # Argumentos: Nenhum.
  # Retorno: O objeto `Usuario` que respondeu a este formulário.
  # Efeitos colaterais: Define um método `respondente` e `respondente=` para gerenciar a associação.
  belongs_to :respondente, class_name: "Usuario"

  ##
  # Associação: Possui muitas `RespostaQuestoes`.
  #
  # Descrição: Define a relação onde uma `RespostaFormulario` pode ter múltiplas
  #    `RespostaQuestoes` associadas a ela, representando as respostas individuais
  #    para cada pergunta do formulário. Quando uma resposta de formulário é destruída,
  #    todas as suas respostas de questão associadas também são destruídas (`dependent: :destroy`).
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `RespostaQuestao` associados a esta resposta de formulário.
  # Efeitos colaterais: Ao destruir uma `RespostaFormulario`, suas `RespostaQuestoes` dependentes também são destruídas.
  has_many :respostas_questoes, class_name: "RespostaQuestao", dependent: :destroy

  ##
  # Validação: Garante a presença do `formulario_id`.
  #
  # Descrição: Assegura que um `formulario_id` seja fornecido ao criar ou atualizar
  #    uma `RespostaFormulario`, garantindo que a resposta esteja sempre associada
  #    a um formulário existente.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `formulario_id` estiver ausente.
  validates :formulario_id, presence: true

  ##
  # Validação: Garante a presença do `respondente_id`.
  #
  # Descrição: Assegura que um `respondente_id` seja fornecido ao criar ou atualizar
  #    uma `RespostaFormulario`, garantindo que a resposta esteja sempre associada
  #    a um usuário que a respondeu.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `respondente_id` estiver ausente.
  validates :respondente_id, presence: true

  ##
  # Validação: Garante a unicidade da combinação `formulario_id` e `respondente_id`.
  #
  # Descrição: Impede que um mesmo usuário responda ao mesmo formulário múltiplas vezes.
  #    A mensagem de erro personalizada "Você já respondeu este formulário" é exibida
  #    se esta validação falhar.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se a combinação não for única.
  validates :formulario_id, uniqueness: { scope: :respondente_id, message: "Você já respondeu este formulário" }
end
