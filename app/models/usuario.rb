class Usuario < ApplicationRecord
  attr_writer :login

  def login
    @login || self.email || self.matricula
  end

  def admin?
    self.admin == true
  end

  # ✅ Reativando o validatable!
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

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