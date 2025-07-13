# spec/factories/usuarios.rb
FactoryBot.define do
  factory :usuario do
    nome { Faker::Name.name }
    email { Faker::Internet.unique.email }
    matricula { Faker::Number.unique.number(digits: 9).to_s }
    
    # ADICIONADO: Garante que todo utilizador criado pela fábrica
    # tenha uma senha e seja válido para o Devise.
    password { 'password123' }
    password_confirmation { 'password123' }
    
    admin { false }
    
    trait :admin do
      admin { true }
    end

    # O trait :sem_senha não é mais necessário, pois o nosso teste
    # agora cria um utilizador válido e depois gera o token.
  end

  # A factory de password_reset_token não é mais usada,
  # mas pode deixá-la aqui se for usada em outros testes.
  factory :password_reset_token do
    association :usuario
    token { SecureRandom.urlsafe_base64(32) }
    expires_at { 24.hours.from_now }
    used { false }
  end
end
