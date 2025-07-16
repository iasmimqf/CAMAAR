require 'cucumber/rails'
require 'factory_bot_rails'
require 'database_cleaner/active_record'

# Define a estratégia. Truncation é a mais segura.
DatabaseCleaner.strategy = :truncation

include Warden::Test::Helpers

# --- INÍCIO DA SOLUÇÃO ---
# Este bloco é um "gancho" que roda antes de cada cenário
Before do
  # A linha abaixo coloca o Warden (motor do Devise) em "modo de teste",
  # o que garante que helpers como 'login_as' estejam prontos para uso.
  Warden.test_mode!

  # E esta linha garante que o banco de dados seja limpo.
  DatabaseCleaner.clean_with(:truncation)
end
# --- FIM DA SOLUÇÃO ---

# O After hook limpa a sessão e reseta o modo de teste.
After do
  Warden.test_reset!
  logout
end

World(FactoryBot::Syntax::Methods)