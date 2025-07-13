# spec/factories/usuarios.rb
FactoryBot.define do
  factory :usuario do # Nome do modelo em minúsculo
    nome { Faker::Name.name }
    email { Faker::Internet.unique.email }
    matricula { Faker::Number.unique.number(digits: 9).to_s }
    # password { 'senha123' } # Mantenha ou remova, mas o trait abaixo vai sobrescrever para nil
    admin { false }
    
    trait :sem_senha do
      password { nil } # Define a senha como nula para este trait
      # Se seu modelo Usuario usa Devise ou `has_secure_password`
      # e a validação de presença é forte, você pode precisar de algo como:
      # after(:build) { |u| u.skip_password_validation = true if u.respond_to?(:skip_password_validation=) }
      # Isso implicaria adicionar `attr_accessor :skip_password_validation` no seu modelo Usuario
      # e `validates :password, presence: true, unless: :skip_password_validation` no modelo.
      # No entanto, a solução mais simples é combinar com a próxima alteração no step definition.
    end

    trait :admin do
      admin { true }
    end
  end

  # ... (sua factory para :password_reset_token deve estar aqui também) ...
  factory :password_reset_token do
    association :usuario
    token { SecureRandom.urlsafe_base64(32) }
    expires_at { 24.hours.from_now }
    used { false }
  end
end