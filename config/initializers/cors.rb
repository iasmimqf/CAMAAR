# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Permite pedidos da origem onde o seu frontend Next.js está a correr
    origins "http://localhost:3002"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true, # Mantém esta linha, ela é importante para outras requisições

      # ===============================================================
      # ▼▼▼ ADICIONE ESTA LINHA ABAIXO ▼▼▼
      # ===============================================================
      # Expõe o cabeçalho 'Authorization' para que o frontend possa lê-lo.
      expose:  [ "Authorization" ]
    # ===============================================================
  end
end
