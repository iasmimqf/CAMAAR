# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Permite pedidos da origem onde o seu frontend Next.js está a correr
    # O seu código usa a porta 3002, o que está correto.
    origins "http://localhost:3002"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      # <<< LINHA CRUCIAL ADICIONADA AQUI
      # Essencial para permitir que o frontend envie cookies de sessão
      credentials: true
  end
end
