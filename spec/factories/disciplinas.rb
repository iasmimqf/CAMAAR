# spec/factories/turmas.rb
FactoryBot.define do
  factory :disciplina do
    nome { "BANCOS DE DADOS" }
    codigo { |n| "CIC#{n.to_s.rjust(4, '0')}" }
    descricao { "Disciplina sobre conceitos e implementação de bancos de dados" }
  end
end
