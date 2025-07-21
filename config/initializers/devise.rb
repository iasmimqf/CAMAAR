# Caminho: config/initializers/devise.rb
Devise.setup do |config|
  config.mailer_sender = "camaarkk@gmail.com"
  config.mailer = "CustomDeviseMailer"
  require "devise/orm/active_record"
  config.authentication_keys = [ :login ]
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]

  # Altera para um array vazio para desativar explicitamente o pulo de armazenamento de sessão.
  # Isso garante que o Devise use cookies de sessão.
  config.skip_session_storage = []

  config.password_length = 10..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reconfirmable = true

  # Esta linha pode ser removida se você não usa 'remember me'.
  # config.expire_all_remember_me_on_sign_out = true

  config.reset_password_within = 6.hours
  config.sign_in_after_reset_password = false
  config.scoped_views = true
  config.navigational_formats = [ :html, :turbo_stream ]
  config.sign_out_via = :delete
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
