# app/models/questao.rb
class Questao < ApplicationRecord
  self.table_name = "questoes"

  # --- Associações ---
  belongs_to :template
  has_many :resposta_questoes, class_name: "RespostaQuestao", dependent: :destroy

  # --- Validações ---
  validates :enunciado, presence: { message: "O enunciado é obrigatório" }
  validates :tipo, presence: true, inclusion: { in: %w[Escala Texto Checkbox], message: "%{value} não é um tipo de questão válido" }
  validates :obrigatoria, inclusion: { in: [true, false] }

  # --- Métodos para lidar com o campo 'opcoes' ---

  # Garante que as opções sejam salvas como uma string separada por vírgulas
  def opcoes=(value)
    if value.is_a?(Array)
      super(value.join(','))
    else
      super(value)
    end
  end

  # Retorna as opções como um array de strings
  def opcoes_array
    return [] if opcoes.blank?
    opcoes.split(",").map(&:strip)
  end

  def opcoes_array=(array)
    self.opcoes = array.join(",") if array.present?
  end
end

