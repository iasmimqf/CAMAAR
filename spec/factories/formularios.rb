FactoryBot.define do
  factory :formulario do
    association :criador, factory: :usuario
    association :template

    # Adicione outros atributos conforme necessário
    # Por exemplo, se houver campos como título, descrição, etc.
  end
end
