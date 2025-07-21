source "https://rubygems.org"

# Rails e suas principais dependências
gem "rails", "~> 7.1.5"
gem "hotwire-rails"
gem "propshaft" # O moderno asset pipeline para Rails
gem "sqlite3", ">= 2.1" # Banco de dados SQLite
gem "puma", ">= 5.0" # Servidor web
gem "importmap-rails" # JavaScript com ESM import maps
gem "turbo-rails" # Hotwire's SPA-like page accelerator
gem "stimulus-rails" # Hotwire's JavaScript framework
gem "jbuilder" # Para construir JSON APIs
gem "solid_cache" # Adaptador para Rails.cache
gem "solid_queue" # Adaptador para Active Job
gem "solid_cable" # Adaptador para Action Cable

# Medir a Complexidade do Código
gem 'rubycritic', require: false

# Autenticação
gem 'devise'
gem 'devise-i18n' # Internacionalização para Devise

# CORS (Cross-Origin Resource Sharing)
gem 'rack-cors'

# Detecção de navegador (geralmente útil em todos os ambientes)
gem 'browser'

# Gems comumente usadas em todos os ambientes ou em ambientes específicos
# que estavam no grupo :test mas que provavelmente são para development/production
gem 'cocoon'            # Para nested forms (depende de jQuery)
gem 'jquery-rails'      # Dependência do Cocoon (JQuery)
gem 'kaminari'          # Para paginação
gem 'font-awesome-sass' # Ícones

# Reduz boot times através de caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy as Docker container
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma
gem "thruster", require: false

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use Active Storage variants
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker" # Ótima para gerar dados falsos nas factories

  # Debugging
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities
  gem "brakeman", require: false

  # Omakase Ruby styling
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages
  gem "web-console"
  gem "letter_opener_web"
end

group :test do
  # Para testes BDD
  gem "cucumber-rails", require: false
  gem "database_cleaner-active_record"

  #para teste de cobertura
  gem 'simplecov', require: false

  # Use system testing
  gem "capybara"
  gem "selenium-webdriver"
end