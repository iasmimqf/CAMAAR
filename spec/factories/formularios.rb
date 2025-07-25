# spec/factories/formularios.rb
FactoryBot.define do
  factory :formulario do
    # Associa a um template e a um criador
    association :criador, factory: :usuario
    association :template

    # Associa a uma turma por padrão
    after(:build) do |formulario|
      formulario.turmas << build(:turma) if formulario.turmas.empty?
    end

    # Define a data de expiração padrão
    dataDeExpiracao { 1.week.from_now }

    # Callback para preencher o estruturaJSON com base no template associado
    after(:build) do |formulario|
      if formulario.template
        questoes_json = formulario.template.questoes.map do |q|
          { id: q.id, enunciado: q.enunciado, tipo: q.tipo, obrigatoria: q.obrigatoria, opcoes: q.opcoes }
        end
        formulario.estruturaJSON = { questoes: questoes_json }.to_json
      end
    end

    # Traits para testes de status
    trait :ativo do
      dataDeExpiracao { 1.day.from_now }
    end

    trait :expirado do
      dataDeExpiracao { 1.day.ago }
    end
  end
end