# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Permite requisições do seu frontend (porta 3002)
    origins 'http://localhost:3002' 

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      # LINHA ADICIONADA: Expõe os cabeçalhos de autenticação para o navegador
      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client']
  end
end