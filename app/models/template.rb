# Model que representa um Template de Formulário
#
# Um Template é um modelo que define a estrutura de perguntas que serão
# utilizadas na criação de formulários. Cada template pertence a um usuário
# criador e pode ter múltiplas questões associadas.
#
# Relacionamentos:
# - belongs_to :criador (Usuario) - usuário que criou o template
# - has_many :questoes - perguntas do template
# - has_many :formularios - formulários baseados neste template
#
# Validações:
# - titulo deve estar presente e ser único
# - deve ter pelo menos uma questão (exceto quando skip_questoes_validation = true)
class Template < ApplicationRecord
  belongs_to :criador, class_name: 'Usuario'
  has_many :questoes, class_name: 'Questao', dependent: :destroy
  has_many :formularios

  validates :titulo, presence: { message: "O título do template é obrigatório" }, 
                     uniqueness: { message: "Já existe um template com este nome. Use um título diferente." }
  validate :questoes_presentes, unless: :skip_questoes_validation

  accepts_nested_attributes_for :questoes, allow_destroy: true, 
                               reject_if: proc { |attributes| attributes['enunciado'].blank? && attributes['tipo'].blank? }

  # Permite pular a validação de questões durante criação programática
  attr_accessor :skip_questoes_validation

  # Scope para templates com questões
  scope :com_questoes, -> { joins(:questoes).distinct }
  
  # Scope para templates de um criador específico
  scope :do_criador, ->(usuario) { where(criador: usuario) }

  private

  def questoes_presentes
    errors.add(:base, "Adicione pelo menos uma questão ao template") if questoes.empty?
  end
end
