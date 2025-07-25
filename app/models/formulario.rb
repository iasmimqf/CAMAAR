# Caminho: app/models/formulario.rb

##
# Representa um formulário de avaliação.
#
# Descrição: Este modelo gerencia a criação e associação de formulários
#    a templates, turmas e usuários criadores. Ele também lida com as
#    respostas enviadas para cada formulário.
class Formulario < ApplicationRecord
  ##
  # Associação: Relacionamento Muitos-para-Muitos com `Turmas`.
  #
  # Descrição: Um formulário pode estar associado a várias turmas, e uma turma
  #    pode ter vários formulários. Esta associação é gerenciada por uma
  #    tabela de junção implícita.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Turma` associados a este formulário.
  # Efeitos colaterais: Gerencia a associação entre Formularios e Turmas.
  has_and_belongs_to_many :turmas

  ##
  # Associação: Pertence a um `Criador` (Usuário).
  #
  # Descrição: Define a relação onde cada `Formulario` tem um `Usuario`
  #    que o criou. O `class_name` é especificado como "Usuario" porque
  #    o nome da associação (`criador`) difere do nome da classe (`Usuario`).
  # Argumentos: Nenhum.
  # Retorno: O objeto `Usuario` que criou este formulário.
  # Efeitos colaterais: Define um método `criador` e `criador=` para gerenciar a associação.
  belongs_to :criador, class_name: "Usuario"

  ##
  # Associação: Pertence a um `Template`.
  #
  # Descrição: Define a relação onde cada `Formulario` está baseado em um
  #    `Template` específico, que define as questões do formulário.
  # Argumentos: Nenhum.
  # Retorno: O objeto `Template` ao qual este formulário pertence.
  # Efeitos colaterais: Define um método `template` e `template=` para gerenciar a associação.
  belongs_to :template

  ##
  # Associação: Possui muitas `RespostaFormularios`.
  #
  # Descrição: Define a relação onde um `Formulario` pode ter múltiplas
  #    `RespostaFormularios` associadas a ele, representando as respostas
  #    completas de diferentes usuários. Quando um formulário é destruído,
  #    todas as suas respostas associadas também são destruídas (`dependent: :destroy`).
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `RespostaFormulario` associados a este formulário.
  # Efeitos colaterais: Ao destruir um `Formulario`, suas `RespostaFormularios` dependentes também são destruídas.
  has_many :resposta_formularios, dependent: :destroy

  ##
  # Associação: Possui muitas `Respostas`.
  #
  # Descrição: Esta associação é um alias ou um relacionamento mais genérico
  #    que pode ser usado para acessar as respostas relacionadas ao formulário.
  #    Dependendo da estrutura, pode ser redundante se `resposta_formularios` já cobre o caso.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Resposta` (assumindo que `Resposta` seja um modelo válido).
  # Efeitos colaterais: Define um método `respostas` e `respostas=` para gerenciar a associação.
  has_many :respostas # Assumindo que 'respostas' é um modelo válido ou um alias para resposta_formularios

  ##
  # Validação: Garante a presença do `template_id`.
  #
  # Descrição: Assegura que um `template_id` seja fornecido ao criar um `Formulario`,
  #    garantindo que cada formulário esteja sempre associado a um template.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `template_id` estiver ausente.
  validates :template_id, presence: { message: "Você deve selecionar um template" }

  ##
  # Validação customizada: Garante que o formulário tenha pelo menos uma turma associada.
  #
  # Descrição: Este método de validação customizada verifica se o formulário
  #    possui pelo menos uma turma selecionada. Se nenhuma turma for associada,
  #    um erro é adicionado ao objeto.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se nenhuma turma for associada.
  validate :deve_ter_pelo_menos_uma_turma

  private

  ##
  # Método privado de validação: Verifica se há pelo menos uma turma associada.
  #
  # Descrição: Implementa a lógica para verificar se a coleção de `turmas`
  #    associadas ao formulário está vazia. Se estiver, adiciona uma mensagem
  #    de erro ao atributo `:turmas` do formulário.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito. Adiciona erros ao objeto `errors` se a validação falhar.
  # Efeitos colaterais: Modifica o objeto `errors` do `Formulario`.
  def deve_ter_pelo_menos_uma_turma
    if turmas.empty?
      errors.add(:turmas, "Você deve selecionar ao menos uma turma")
    end
  end
end
