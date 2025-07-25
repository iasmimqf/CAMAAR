# app/models/template.rb
class Template < ApplicationRecord
  # Associações
  # Se um formulário estiver a usar este template, a exclusão será impedida.
  belongs_to :criador, class_name: "Usuario"
  has_many :formularios, dependent: :restrict_with_error
  has_many :questoes, class_name: 'Questao', dependent: :destroy

  # Validações
  validates :titulo, presence: { message: "O título do template é obrigatório" }, uniqueness: { message: "Já existe um template com este nome. Use um título diferente." }
  validate :questoes_presentes

<<<<<<< HEAD
  # MODIFICADO: Unifique a lógica de validação de questoes_presentes
  validate :questoes_presentes, unless: :skip_questoes_validation

  # MODIFICADO: Ajuste no reject_if para lidar melhor com _destroy
  accepts_nested_attributes_for :questoes, allow_destroy: true, reject_if: proc { |attributes| attributes["id"].blank? && attributes["enunciado"].blank? && attributes["tipo"].blank? }

  # Permite pular a validação de questões durante criação programática
  attr_accessor :skip_questoes_validation

  # Scope para templates com questões
  scope :com_questoes, -> { joins(:questoes).distinct }

  # Scope para templates de um criador específico
  # scope :do_criador, ->(usuario) { where(criador: usuario) }
=======
  # Atributos aninhados para questões
  accepts_nested_attributes_for :questoes, allow_destroy: true, reject_if: proc { |attributes| attributes['enunciado'].blank? }
>>>>>>> 45470b0075447feb0d3b821b202008e316924ac0

  private

  def questoes_presentes
    # Garante que o template tenha pelo menos uma questão válida (não marcada para exclusão).
    valid_questoes = questoes.reject(&:marked_for_destruction?)
    errors.add(:base, "Adicione pelo menos uma questão ao template") if valid_questoes.empty?
  end
end
