# spec/factories/usuarios.rb
FactoryBot.define do
  factory :usuario do # Nome do modelo em minúsculo
    nome { Faker::Name.name }
    email { Faker::Internet.unique.email }
    matricula { Faker::Number.unique.number(digits: 9).to_s }
    password { 'senha123' }
    admin { false }

    # Isso cria uma "variante" da factory para o admin
    trait :admin do
      admin { true }
    end
  end
end