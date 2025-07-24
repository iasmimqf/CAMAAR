# features/support/env.rb
require 'cucumber/rails'
require 'capybara/cucumber'
require 'capybara/rspec'
require 'factory_bot_rails'
require 'database_cleaner/active_record'
require 'rspec/mocks/standalone'

DatabaseCleaner.strategy = :truncation

include Warden::Test::Helpers

Before do
  Warden.test_mode!
  DatabaseCleaner.clean_with(:truncation)
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
