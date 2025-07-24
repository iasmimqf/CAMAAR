# app/models/questao.rb
class Questao < ApplicationRecord
  self.table_name = 'questoes'

  # Associações
  belongs_to :template
  has_many :resposta_questoes, class_name: 'RespostaQuestao', dependent: :destroy

  # Validações
  validates :enunciado, presence: { message: "O enunciado é obrigatório" }
  validates :tipo, presence: true, inclusion: { in: %w[Escala Texto Checkbox], message: "%{value} não é um tipo de questão válido" }
  validates :obrigatoria, inclusion: { in: [true, false] }

  # ===============================================================
  # ▼▼▼ CORREÇÃO APLICADA AQUI ▼▼▼
  # ===============================================================
  # Este método é chamado sempre que tentamos guardar as opções.
  # Ele garante que, se recebermos um array (vindo do frontend),
  # ele será convertido para um texto separado por vírgulas antes de ser salvo.
  def opcoes=(value)
    if value.is_a?(Array)
      # Converte o array ['a', 'b'] para a string "a,b"
      super(value.join(','))
    else
      # Se já for um texto, guarda-o como está.
      super(value)
    end
  end
  # ===============================================================

  # Métodos auxiliares para lidar com as opções
  def opcoes_array
    return [] if opcoes.blank?
    opcoes.split(',').map(&:strip)
  end

  def opcoes_array=(array)
    self.opcoes = array.join(',') if array.present?
  end
end
