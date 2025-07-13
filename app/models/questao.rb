class Questao < ApplicationRecord
  self.table_name = 'questoes'
  
  belongs_to :template

  validates :enunciado, presence: { message: "O enunciado é obrigatório" }
  validates :tipo, presence: true, inclusion: { in: %w[Escala Texto] }
  validates :obrigatoria, inclusion: { in: [true, false] }

  # Para questões do tipo escala, armazenar as opções como string separada por vírgula
  # Exemplo: "5,4,3,2,1"
  def opcoes_array
    return [] if opcoes.blank?
    opcoes.split(',').map(&:strip)
  end

  def opcoes_array=(array)
    self.opcoes = array.join(',') if array.present?
  end
end
