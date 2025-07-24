class CreateDisciplinasAndTurmas < ActiveRecord::Migration[7.1]
  def change
    create_table :disciplinas, id: false do |t|  # desabilita o id autoincrementado
      t.string :codigo, primary_key=true  # Ex: "CIC0097"
      t.string :nome, null: false    # Ex: "BANCOS DE DADOS"
      t.text :descricao
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [ :codigo ], unique: true
    end

    create_table :turmas, id: false do |t|
      t.string :codigo_turma, null: false  # Ex: "TA", "TB"
      t.string :semestre, null: false      # Ex: "2023.1"
      t.string :horario                    # Ex: "35T45"
      t.string :disciplina_codigo, null: false  # FK para disciplinas.codigo
      t.references :professor, null: false, foreign_key: { to_table: :usuarios }
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      # Chave primária composta
      t.primary_key [ :disciplina_codigo, :codigo_turma, :semestre ]

      # Índice para a FK
      t.index [ :disciplina_codigo ], name: 'index_turmas_on_disciplina_codigo'
    end
  end
end
