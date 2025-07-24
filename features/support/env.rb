# features/support/env.rb
require 'cucumber/rails'
require 'capybara/cucumber'
require 'capybara/rspec'
require 'factory_bot_rails'

# Carrega os modelos do Rails
require Rails.root.join('config', 'environment')

# Inclui métodos do FactoryBot
World(FactoryBot::Syntax::Methods)

# Configurações do Capybara
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_headless

# Para testes com JavaScript
Capybara.register_driver :selenium_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Configurações do banco de dados para testes
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

# Hooks para limpeza
Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end

# features/support/login_helpers.rb
module LoginHelpers
  def fazer_login_como(usuario)
    visit new_usuario_session_path
    fill_in 'Email', with: usuario.email
    fill_in 'Senha', with: 'AdminPassword123!'
    click_button 'Log in'
  end
end

World(LoginHelpers)

# features/support/login_helpers.rb
require 'warden/test/helpers'

module LoginHelpers
  include Warden::Test::Helpers

  def login_as(user, options = {})
    scope = options[:scope] || :usuario
    # Usar o método correto do Warden
    Warden.test_mode!
    super(user, scope: scope)
    visit root_path unless options[:no_visit]
  end

  def logout
    Warden.test_reset! if Warden.test_mode?
  end
end

World(LoginHelpers)
