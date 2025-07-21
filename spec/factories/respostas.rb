# spec/factories/respostas.rb
FactoryBot.define do
  factory :resposta do
    association :formulario
    association :avaliador, factory: :usuario
  end
end
