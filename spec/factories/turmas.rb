FactoryBot.define do
  factory :turma do
    association :disciplina
    codigo_turma { "T1" }
    semestre { "2025.1" }
    horario { "35T45" }
  end
end
