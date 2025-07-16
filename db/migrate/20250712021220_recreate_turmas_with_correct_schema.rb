class RecreateTurmasWithCorrectSchema < ActiveRecord::Migration[7.1]
  def change
    # Apaga a tabela 'turmas' antiga, se ela existir.
    drop_table :turmas, if_exists: true

    # Cria a tabela 'turmas' novamente com a estrutura final e correta.
    create_table :turmas do |t|
      # Chave primária 'id' é criada automaticamente.
      t.string "codigo_turma", null: false
      t.string "semestre", null: false
      t.string "horario"

      # Chave estrangeira
      t.references :disciplina, null: false, foreign_key: true
      t.references :professor, null: true, foreign_key: { to_table: :usuarios }

      t.timestamps
    end

    # O índice para garantir que a combinação da turma é única.
    add_index :turmas, [:disciplina_id, :codigo_turma, :semestre], unique: true, name: 'index_turmas_on_unique_keys'
  end
end
