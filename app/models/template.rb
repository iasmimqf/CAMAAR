# app/models/template.rb
class Template < ApplicationRecord
  # COMENTE ESTA LINHA POR ENQUANTO. Ela exige um criador que não está sendo passado.
  # belongs_to :criador, class_name: 'Usuario'

  # Se você tiver uma coluna 'criador_id' no banco, mas não está preenchendo agora:
  # validates :criador_id, presence: false, allow_nil: true # Isso é um exemplo, se a coluna existir

  has_many :questoes, class_name: 'Questao', dependent: :destroy
  has_many :formularios # Confirme se 'formularios' existe no seu banco e modelo.

  validates :titulo, presence: { message: "O título do template é obrigatório" }, uniqueness: { message: "Já existe um template com este nome. Use um título diferente." }

  # === MANTENHA ESTA LINHA DESCOMENTADA para reativar a validação de questões ===
  validate :questoes_presentes, unless: :skip_questoes_validation

  # MODIFICADO: Ajuste no reject_if para lidar melhor com _destroy
  # A condição agora é: rejeitar se for uma questão NOVA (sem ID) E estiver vazia.
  # Questões com ID (existentes) ou com _destroy: true serão sempre processadas.
  accepts_nested_attributes_for :questoes, allow_destroy: true, reject_if: proc { |attributes| attributes['id'].blank? && attributes['enunciado'].blank? && attributes['tipo'].blank? }

  attr_accessor :skip_questoes_validation

  private

  # === DEFINIÇÃO CORRETA E ÚNICA DE questoes_presentes ===
  def questoes_presentes
    # Esta lógica verifica as questões que *não* estão marcadas para destruição
    # E que não estão em branco (se for uma questão nova que seria rejeitada pelo reject_if).
    valid_questoes = questoes.reject do |q|
      # Verifica se a questão está marcada para destruir OU
      # (Se for um novo registro E enunciado estiver vazio E tipo estiver vazio)
      q._destroy || (q.new_record? && q.enunciado.blank? && q.tipo.blank?)
    end
    errors.add(:base, "Adicione pelo menos uma questão ao template") if valid_questoes.empty?
  end
end # Fim da classe Template (deve ser o ÚNICO 'end' final)