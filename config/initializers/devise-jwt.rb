# config/initializers/devise-jwt.rb

Warden::JWTAuth.configure do |config|
  # Pega a chave secreta das suas credenciais encriptadas
  config.secret = Rails.application.credentials.devise_jwt_secret_key

  # ESTA É A REGRA MAIS IMPORTANTE
  # Ela diz ao devise-jwt: "Quando uma requisição POST for bem-sucedida
  # na rota /usuarios/sign_in, você DEVE gerar e enviar um token."
  config.dispatch_requests = [
    ['POST', %r{^/usuarios/sign_in$}]
  ]

  # Esta regra lida com o logout
  config.revocation_requests = [
    ['DELETE', %r{^/usuarios/sign_out$}]
  ]
  
  # Define o tempo de expiração do token
  config.expiration_time = 1.day.to_i
end