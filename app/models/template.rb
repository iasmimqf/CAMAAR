# app/models/template.rb
class Template < ApplicationRecord
  # Associações
  # Se um formulário estiver a usar este template, a exclusão será impedida.
  belongs_to :criador, class_name: "Usuario"
  has_many :formularios, dependent: :restrict_with_error
  has_many :questoes, class_name: "Questao", dependent: :destroy

  # Validações
  validates :titulo, presence: { message: "O título do template é obrigatório" }, uniqueness: { message: "Já existe um template com este nome. Use um título diferente." }
  validate :questoes_presentes

  # Atributos aninhados para questões
  accepts_nested_attributes_for :questoes, allow_destroy: true, reject_if: proc { |attributes| attributes["enunciado"].blank? }

  private

  def questoes_presentes
    # Garante que o template tenha pelo menos uma questão válida (não marcada para exclusão).
    valid_questoes = questoes.reject(&:marked_for_destruction?)
    errors.add(:base, "Adicione pelo menos uma questão ao template") if valid_questoes.empty?
  end
end
