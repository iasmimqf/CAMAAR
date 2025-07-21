FactoryBot.define do
  factory :formulario do
    association :criador, factory: [ :usuario, :admin ]
    association :template

    # Adicione outros atributos conforme necessário
    # Por exemplo, se houver campos como título, descrição, etc.
  end
end
