# features/support/env.rb

require 'cucumber/rails'
require 'factory_bot_rails'
require 'database_cleaner/active_record'

# --- Configuração do Capybara e Selenium ---
require 'capybara/cucumber'
require 'selenium-webdriver'

Capybara.configure do |config|
  config.default_driver = :selenium_chrome_headless
  config.app_host = 'http://127.0.0.1:3000'
  config.default_max_wait_time = 5
end

# --- Configuração do Database Cleaner ---
DatabaseCleaner.strategy = :truncation

include Warden::Test::Helpers
World(FactoryBot::Syntax::Methods)

# --- Hooks do Cucumber (Antes e Depois de cada cenário) ---

# O Around hook garante que todo o código dentro de um cenário
# seja executado com o idioma correto.
Around do |scenario, block|
  I18n.with_locale(:'pt-BR', &block)
end

Before do
  Warden.test_mode!
  DatabaseCleaner.clean_with(:truncation)
end

After do
  Warden.test_reset!
  logout
end
