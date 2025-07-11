require 'cucumber/rails'
require 'factory_bot_rails'
require 'database_cleaner/active_record'

# Define a estratégia. Truncation é a mais segura.
DatabaseCleaner.strategy = :truncation

# Inclui os métodos do FactoryBot
World(FactoryBot::Syntax::Methods)

# Limpa o banco de dados ANTES de cada cenário
Before do
  DatabaseCleaner.clean
end