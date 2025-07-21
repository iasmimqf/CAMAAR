# app/models/questao.rb
class Questao < ApplicationRecord
  self.table_name = "questoes"

  belongs_to :template
  has_many :resposta_questoes, class_name: "RespostaQuestao", dependent: :destroy

  validates :enunciado, presence: { message: "O enunciado é obrigatório" }

  # === MUDANÇA AQUI: Adicionar 'Checkbox' e 'Radio' (com 'R' maiúsculo) ===
  validates :tipo, presence: true, inclusion: { in: %w[Escala Texto Checkbox], message: "%{value} não é um tipo de questão válido" }

  validates :obrigatoria, inclusion: { in: [ true, false ] }

  def opcoes_array
    return [] if opcoes.blank?
    opcoes.split(",").map(&:strip)
  end

  def opcoes_array=(array)
    self.opcoes = array.join(",") if array.present?
  end
end
