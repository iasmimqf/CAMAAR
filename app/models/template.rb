class Template < ApplicationRecord
  belongs_to :criador, class_name: 'Usuario'
  has_many :questoes, class_name: 'Questao', dependent: :destroy
  has_many :formularios

  validates :titulo, presence: { message: "O título do template é obrigatório" }, uniqueness: { message: "Já existe um template com este nome. Use um título diferente." }
  validate :questoes_presentes, unless: :skip_questoes_validation

  accepts_nested_attributes_for :questoes, allow_destroy: true, reject_if: proc { |attributes| attributes['enunciado'].blank? && attributes['tipo'].blank? }

  attr_accessor :skip_questoes_validation

  private

  def questoes_presentes
    errors.add(:base, "Adicione pelo menos uma questão ao template") if questoes.empty?
  end
end
