# app/models/usuario.rb
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

  def formularios_pendentes
    return Formulario.none if self.turmas.empty?
    
    formularios_das_turmas = Formulario.joins(:turmas)
                                       .where(turmas: { id: self.turmas.pluck(:id) })
                                       .distinct
    
    formularios_respondidos_ids = self.resposta_formularios.pluck(:formulario_id)
    formularios_das_turmas.where.not(id: formularios_respondidos_ids)
  end

  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # ===============================================================
  # ▼▼▼ CORREÇÃO PRINCIPAL AQUI ▼▼▼
  # ===============================================================
  # A classe NullDenylist agora tem o método `jwt_revoked?` que a gem espera.
  class NullDenylist
    def self.revoke_jti(jti, exp)
      # Para a estratégia nula, este método não faz nada.
    end

    def self.jti_revoked?(jti)
      # A estratégia nula nunca considera um token como revogado.
      false
    end

    # Método de fallback para satisfazer a gem `warden-jwt-auth`
    def self.jwt_revoked?(payload, user)
      # Apenas delega para o método que já tínhamos.
      jti_revoked?(payload['jti'])
    end
  end
  # ===============================================================

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
