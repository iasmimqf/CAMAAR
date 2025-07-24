# app/models/usuario.rb
class Usuario < ApplicationRecord
  attr_writer :login

  # Relacionamentos
  has_many :resposta_formularios, foreign_key: "respondente_id", dependent: :destroy
  has_and_belongs_to_many :turmas
  has_many :formularios, foreign_key: "criador_id", dependent: :destroy

  def login
    @login || self.email || self.matricula
  end

  def admin?
    self.admin == true
  end

  # ===============================================================
  # ▼▼▼ MÉTODO ATUALIZADO COM FILTRO DE PRAZO ▼▼▼
  # ===============================================================
  def formularios_pendentes
    return Formulario.none if self.turmas.empty?
    
    formularios_das_turmas = Formulario.joins(:turmas)
                                       .where(turmas: { id: self.turmas.pluck(:id) })
                                       # Adiciona a condição para o prazo:
                                       # O prazo deve ser NULO (sem prazo) OU estar no futuro.
                                       .where("formularios.prazo IS NULL OR formularios.prazo > ?", Time.current)
                                       .distinct
    
    formularios_respondidos_ids = self.resposta_formularios.pluck(:formulario_id)
    formularios_das_turmas.where.not(id: formularios_respondidos_ids)
  end
  # ===============================================================

  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  class NullDenylist
    def self.revoke_jti(jti, exp); end
    def self.jti_revoked?(jti); false; end
    def self.jwt_revoked?(payload, user); jti_revoked?(payload['jti']); end
  end

  self.jwt_revocation_strategy = NullDenylist

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

  has_many :turmas_lecionadas, class_name: 'Turma', foreign_key: 'professor_id'
  has_many :formularios_criados, class_name: 'Formulario', foreign_key: 'criador_id'
  has_many :respostas_enviadas, class_name: 'Resposta', foreign_key: 'avaliador_id'
end
