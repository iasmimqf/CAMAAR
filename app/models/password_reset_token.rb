# app/models/password_reset_token.rb
class PasswordResetToken < ApplicationRecord
  # VERIFIQUE E AJUSTE AQUI: Se seu modelo de usuário é 'Usuario', mude :user para :usuario
  belongs_to :usuario

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :used, inclusion: { in: [true, false] }

  def expired?
    expires_at < Time.current
  end

  def used?
    used
  end

  def invalidate!
    update!(used: true)
  end
end