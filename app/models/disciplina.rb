# Caminho: app/models/disciplina.rb

##
# Representa uma disciplina acadêmica.
#
# Descrição: Este modelo armazena informações sobre as disciplinas,
#    como código e nome. Uma disciplina pode ter múltiplas turmas associadas.
class Disciplina < ApplicationRecord
  ##
  # Associação: Possui muitas `Turmas`.
  #
  # Descrição: Define a relação onde uma `Disciplina` pode ter várias `Turmas`
  #    associadas a ela. Quando uma disciplina é destruída, todas as suas
  #    turmas associadas também são destruídas (`dependent: :destroy`).
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Turma` associados a esta disciplina.
  # Efeitos colaterais: Ao destruir uma `Disciplina`, suas `Turmas` dependentes também são destruídas.
  has_many :turmas, dependent: :destroy

  ##
  # Validação: Garante a presença e unicidade do `codigo`.
  #
  # Descrição: Assegura que cada disciplina tenha um código único e presente.
  #    O código é um identificador chave para a disciplina.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `codigo` estiver ausente ou não for único.
  validates :codigo, presence: true, uniqueness: true

  ##
  # Validação: Garante a presença do `nome`.
  #
  # Descrição: Assegura que cada disciplina tenha um nome presente.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `nome` estiver ausente.
  validates :nome, presence: true
end
