class Usuario < ApplicationRecord
  # "atributo virtual" chamado login
  attr_writer :login

  def login
    @login || self.matricula || self.email
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Relacionamento Muitos-para-Muitos: um usuário pode estar em várias turmas.
  has_and_belongs_to_many :turmas

  # Relação de um professor para muitas turmas.
  # A foreign_key especifica que a coluna em 'turmas' é 'professor_id'.
  has_many :turmas_lecionadas, class_name: 'Turma', foreign_key: 'professor_id'

  # Relação de um criador para muitos formulários.
  has_many :formularios_criados, class_name: 'Formulario', foreign_key: 'criador_id'

  # Relação de um avaliador para muitas respostas.
  has_many :respostas_enviadas, class_name: 'Resposta', foreign_key: 'avaliador_id'

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(["matricula = :value OR email = :value", { value: login.downcase }]).first
    elsif conditions.has_key?(:matricula) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end
end