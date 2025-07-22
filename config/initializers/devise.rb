# Caminho: config/initializers/devise.rb
Devise.setup do |config|
  config.mailer_sender = 'camaarkk@gmail.com'
  config.mailer = 'CustomDeviseMailer'
  require 'devise/orm/active_record'
  config.authentication_keys = [:login]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
# Linha correta:
  config.skip_session_storage = [:jwt]
  config.password_length = 10..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reconfirmable = true
  config.reset_password_within = 6.hours
  config.sign_in_after_reset_password = false
  config.scoped_views = true
  config.navigational_formats = [:html, :turbo_stream]
  config.sign_out_via = :delete
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # ===============================================================
  # ▼▼▼ ADICIONE ESTE BLOCO DE CÓDIGO NO FINAL DO SETUP ▼▼▼
  # ===============================================================
  config.jwt do |jwt|
    # Chave secreta para codificar os tokens. Veja como configurar abaixo.
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key!

    # Define para quais requisições o JWT deve ser despachado (login)
    jwt.dispatch_requests = [['POST', %r{^/usuarios/sign_in$}]]

    # Define para quais requisições o JWT deve ser revogado (logout)
    jwt.revocation_requests = [['DELETE', %r{^/usuarios/sign_out$}]]
    
    # Define o tempo de expiração do token
    jwt.expiration_time = 1.day.to_i
  end
  # ===============================================================
end