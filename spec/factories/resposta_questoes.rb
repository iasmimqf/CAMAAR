FactoryBot.define do
  factory :resposta_questao do
    association :resposta_formulario
    association :questao
    valor_resposta { rand(1..5) }
    texto_resposta { "Resposta de exemplo" }
  end
end
