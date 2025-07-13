FactoryBot.define do
  factory :formulario do
    association :criador, factory: [:usuario, :admin]
    association :template
    
    # Cria turmas associadas após a criação
    after(:create) do |formulario|
      turma = create(:turma)
      formulario.turmas << turma
    end
  end
end
