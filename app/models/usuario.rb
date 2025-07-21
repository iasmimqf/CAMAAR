class Usuario < ApplicationRecord
  attr_writer :login

  # Relacionamentos
  has_many :resposta_formularios, foreign_key: 'respondente_id', dependent: :destroy
  has_and_belongs_to_many :turmas
  has_many :formularios, foreign_key: 'criador_id', dependent: :destroy

  def login
    @login || self.email || self.matricula
  end

  def admin?
    self.admin == true
  end

  # Método para buscar formulários pendentes para o aluno
  def formularios_pendentes
    return Formulario.none if self.turmas.empty?
    
    # Busca formulários das turmas do aluno que ainda não foram respondidos
    formularios_das_turmas = Formulario.joins(:turmas)
                                      .where(turmas: { id: self.turmas.pluck(:id) })
                                      .distinct
    
    # Remove formulários já respondidos por este aluno
    formularios_respondidos_ids = self.resposta_formularios.pluck(:formulario_id)
    formularios_das_turmas.where.not(id: formularios_respondidos_ids)
  end

  # ✅ Reativando o validatable!
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable

  validates :password, password_complexity: true, if: -> { new_record? || password.present? }

  def self.password_length
    10..128
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where([
        "lower(email) = :value OR lower(matricula) = :value",
        { value: login.downcase }
      ]).first
    elsif conditions.has_key?(:email) || conditions.has_key?(:matricula)
      where(conditions.to_h).first
    end
  end

  has_and_belongs_to_many :turmas
  has_many :turmas_lecionadas, class_name: 'Turma', foreign_key: 'professor_id'
  has_many :formularios_criados, class_name: 'Formulario', foreign_key: 'criador_id'
  has_many :respostas_enviadas, class_name: 'Resposta', foreign_key: 'avaliador_id'
end