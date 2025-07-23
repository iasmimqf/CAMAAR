require 'cucumber/rails'
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
  Warden.test_reset!
  logout
end

World(FactoryBot::Syntax::Methods)