# features/support/env.rb

require 'cucumber/rails'
require 'factory_bot_rails'
require 'database_cleaner/active_record'

# --- Configuração do Capybara e Selenium (NOVO BLOCO) ---
require 'capybara/cucumber'
require 'selenium-webdriver' # Necessário para interagir com o navegador

# É crucial definir o driver_path para o chromedriver que você instalou manualmente.
# Use o caminho exato que 'which chromedriver' mostrou (ex: /usr/local/bin/chromedriver).
# Se você estiver no WSL, o caminho deve ser o caminho Linux para o driver.
Selenium::WebDriver::Chrome::Service.driver_path = '/usr/local/bin/chromedriver'

Capybara.configure do |config|
  # Usa o Chrome em modo headless (sem interface gráfica visível), que é mais rápido para testes.
  config.default_driver = :selenium_chrome_headless
  # Se você quiser ver o navegador durante os testes para depuração, mude para:
  # config.default_driver = :selenium_chrome

  # Define o host da sua aplicação Rails. Certifique-se que seu servidor Rails
  # esteja rodando nesta URL (ex: `rails s` ou `rails s -p 3000`).
  config.app_host = 'http://127.0.0.1:3000'

  # Tempo máximo que o Capybara vai esperar por um elemento na página.
  config.default_max_wait_time = 5 # segundos
end
# --- FIM da Configuração do Capybara e Selenium ---


# Define a estratégia para limpar o banco de dados antes/depois dos testes.
# Truncation é a mais segura para garantir um estado limpo.
DatabaseCleaner.strategy = :truncation

include Warden::Test::Helpers
# Para usar os métodos do Factory Bot diretamente nos steps, como 'create(:user)'
World(FactoryBot::Syntax::Methods)

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
  logout # Método do Devise/Warden para deslogar um usuário
end