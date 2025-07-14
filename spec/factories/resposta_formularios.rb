FactoryBot.define do
  factory :resposta_formulario do
    association :formulario
    association :respondente, factory: :usuario
  end
end
