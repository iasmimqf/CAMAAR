class Formulario < ApplicationRecord
  # Relacionamento Muitos-para-Muitos: um formulário pode estar em várias turmas.
  has_and_belongs_to_many :turmas

  # Relação de um formulário que pertence a um criador (usuário).
  belongs_to :criador, class_name: "Usuario"

  # Relação de um formulário que pertence a um template.
  belongs_to :template

  # Relacionamento com respostas
  has_many :resposta_formularios, dependent: :destroy

  # Relação de um formulário que tem muitas respostas.
  has_many :respostas

  # Validações
  validates :template_id, presence: { message: "Você deve selecionar um template" }
  validate :deve_ter_pelo_menos_uma_turma

  private

  def deve_ter_pelo_menos_uma_turma
    if turmas.empty?
      errors.add(:turmas, "Você deve selecionar ao menos uma turma")
    end
  end
end
