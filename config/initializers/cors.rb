Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Permite requisições do seu frontend React (que está na porta 3002)
    origins 'http://localhost:3002'

    resource '*', # Permite acesso a todos os seus endpoints da API
      headers: :any, # Permite quaisquer cabeçalhos na requisição
      methods: [:get, :post, :put, :patch, :delete, :options, :head] # Permite os métodos HTTP comuns
  end
end