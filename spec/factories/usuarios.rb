# spec/factories/usuarios.rb
FactoryBot.define do
  factory :usuario do
    nome { Faker::Name.name }
    email { Faker::Internet.unique.email }
    matricula { Faker::Number.unique.number(digits: 9).to_s }
    # password { 'senha123' } # Remova ou comente esta linha, ou use password_digest: nil
    admin { false }

    # Adicione este callback para ignorar validações durante a criação da factory
    # Isso é útil para criar registros em estados "inválidos" para teste.
    # CUIDADO: Use apenas em testes, não em código de produção!
    to_create { |instance| instance.save(validate: false) }
    # Ou, se o problema é só a password:
    # after(:build) { |usuario| usuario.password = nil; usuario.password_confirmation = nil if usuario.respond_to?(:password_confirmation=) }
    # after(:create) { |usuario| usuario.save(validate: false) } # Se precisar salvar sem validação

    # Melhor ainda: use um trait específico para o cenário de criação sem senha
    trait :sem_senha do
      password { nil }
      # Se usar Devise e password_required? for true por padrão, pode precisar de um work-around
      # Exemplo: after(:build) { |u| u.password_required = false } se tiver um atributo temporário
      # Ou usar o to_create acima
    end

    trait :admin do
      admin { true }
    end
  end

  # ... o restante do seu arquivo de factories ...
  factory :password_reset_token do
    association :usuario
    token { SecureRandom.urlsafe_base64(32) }
    expires_at { 24.hours.from_now }
    used { false }
  end
end