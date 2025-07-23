# require 'cucumber/rails'
# require 'factory_bot_rails'
# require 'database_cleaner/active_record'

# # Define a estratégia. Truncation é a mais segura.
# DatabaseCleaner.strategy = :truncation

# include Warden::Test::Helpers

# # --- INÍCIO DA SOLUÇÃO ---
# # Este bloco é um "gancho" que roda antes de cada cenário
# Before do
#   # A linha abaixo coloca o Warden (motor do Devise) em "modo de teste",
#   # o que garante que helpers como 'login_as' estejam prontos para uso.
#   Warden.test_mode!

#   # E esta linha garante que o banco de dados seja limpo.
#   DatabaseCleaner.clean_with(:truncation)
# end
# # --- FIM DA SOLUÇÃO ---

# # O After hook limpa a sessão e reseta o modo de teste.
# After do
#   Warden.test_reset!
#   logout
# end

# World(FactoryBot::Syntax::Methods)

  # features/support/env.rb

require 'cucumber/rails'
require 'factory_bot_rails'
require 'database_cleaner/active_record'

# Inclui os helpers de teste do Warden (que contém o 'login_as')
include Warden::Test::Helpers

# -- Configuração do Database Cleaner --
Before do
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean
end

# -- Limpeza Pós-Teste --
# Desloga qualquer utilizador no final de cada cenário
After do
  logout
end