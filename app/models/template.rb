# app/models/template.rb
class Template < ApplicationRecord
  # COMENTE ESTA LINHA POR ENQUANTO. Ela exige um criador que não está sendo passado.
  # belongs_to :criador, class_name: 'Usuario'

  # Se você tiver uma coluna 'criador_id' no banco, mas não está preenchendo agora:
  # validates :criador_id, presence: false, allow_nil: true # Isso é um exemplo, se a coluna existir

  has_many :questoes, class_name: 'Questao', dependent: :destroy
  has_many :formularios # Confirme se 'formularios' existe no seu banco e modelo.

  validates :titulo, presence: { message: "O título do template é obrigatório" }, uniqueness: { message: "Já existe um template com este nome. Use um título diferente." }

  # MODIFICADO: Unifique a lógica de validação de questoes_presentes
  validate :questoes_presentes, unless: :skip_questoes_validation

  # MODIFICADO: Ajuste no reject_if para lidar melhor com _destroy
  accepts_nested_attributes_for :questoes, allow_destroy: true, reject_if: proc { |attributes| attributes['id'].blank? && attributes['enunciado'].blank? && attributes['tipo'].blank? }

  # Permite pular a validação de questões durante criação programática
  attr_accessor :skip_questoes_validation

  # Scope para templates com questões
  scope :com_questoes, -> { joins(:questoes).distinct }
  
  # Scope para templates de um criador específico
  scope :do_criador, ->(usuario) { where(criador: usuario) }

  private

  # MODIFICADO: Lógica corrigida para 'questoes_presentes'
  def questoes_presentes
    # Uma questão é considerada "válida" se:
    # 1. Não está marcada para _destroy (ignorar as que serão excluídas) E
    # 2. Tem um enunciado preenchido (não é vazia).
    # O `new_record?` é importante para saber se a questão já existia no banco ou é nova.
    
    valid_questoes = questoes.reject do |q|
      q._destroy || # Se está marcada para ser destruída, não conta como presente.
      (q.enunciado.blank? && q.tipo.blank?) # Se enunciado está vazio, é inválida para contagem.
    end

    errors.add(:base, "Adicione pelo menos uma questão ao template") if valid_questoes.empty?
  end
end # Fim da classe Template (deve ser o ÚNICO 'end' final)