# app/models/template.rb
class Template < ApplicationRecord
  # COMENTE ESTA LINHA POR ENQUANTO. Ela exige um criador que não está sendo passado.
  # belongs_to :criador, class_name: 'Usuario'

  # Se você tiver uma coluna 'criador_id' no banco, mas não está preenchendo agora:
  # validates :criador_id, presence: false, allow_nil: true # Isso é um exemplo, se a coluna existir

  has_many :questoes, class_name: 'Questao', dependent: :destroy
  has_many :formularios # Confirme se 'formularios' existe no seu banco e modelo.

  validates :titulo, presence: { message: "O título do template é obrigatório" }, uniqueness: { message: "Já existe um template com este nome. Use um título diferente." }

  # COMENTE ESTA LINHA TAMBÉM POR ENQUANTO. Vamos resolver um erro por vez.
  # validate :questoes_presentes, unless: :skip_questoes_validation

  accepts_nested_attributes_for :questoes, allow_destroy: true, reject_if: proc { |attributes| attributes['enunciado'].blank? && attributes['tipo'].blank? }

  attr_accessor :skip_questoes_validation

  private

  def questoes_presentes
    errors.add(:base, "Adicione pelo menos uma questão ao template") if questoes.empty?
  end
end