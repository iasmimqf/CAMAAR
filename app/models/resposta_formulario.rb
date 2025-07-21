class RespostaFormulario < ApplicationRecord
  belongs_to :formulario
  belongs_to :respondente, class_name: "Usuario"
  has_many :respostas_questoes, class_name: "RespostaQuestao", dependent: :destroy

  validates :formulario_id, presence: true
  validates :respondente_id, presence: true
  validates :formulario_id, uniqueness: { scope: :respondente_id, message: "Você já respondeu este formulário" }
end
