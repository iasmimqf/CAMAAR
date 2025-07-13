class Turma < ApplicationRecord
  belongs_to :disciplina,
             foreign_key: :disciplina_id,
             primary_key: :id,
             inverse_of: :turmas

  belongs_to :professor, class_name: 'Usuario', optional: true
  
  # Relacionamento Muitos-para-Muitos: uma turma pode ter vários formulários
  has_and_belongs_to_many :formularios

  validates :codigo_turma, :semestre, :disciplina_id, presence: true
  validates_uniqueness_of :codigo_turma,
                          scope: [:disciplina_id, :semestre],
                          message: 'já existe uma turma com esta combinação'
  def nome_completo
    "#{disciplina.nome} - #{codigo_turma} (#{semestre})"
  end
end