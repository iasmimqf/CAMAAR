class ChangePrimaryKeyForTurmas < ActiveRecord::Migration[7.1]
  def change
    # Passo 1: Apaga a tabela 'turmas' existente, se ela existir.
    drop_table :turmas, if_exists: true

    # Passo 2: Cria a tabela 'turmas' novamente com a estrutura correta.
    create_table :turmas do |t|
      # O 'id' como chave primária já é o padrão, então não precisa declarar.
      t.string "codigo_turma", null: false
      t.string "semestre", null: false
      t.string "horario"
      t.references :disciplina, null: false, foreign_key: true
      t.references :professor, null: false, foreign_key: { to_table: :usuarios }

      t.timestamps
    end

    # Passo 3: Adiciona o índice de unicidade que você queria.
    # Isso garante que a combinação das 3 colunas seja única.
    add_index :turmas, [ :disciplina_id, :codigo_turma, :semestre ], unique: true, name: 'index_turmas_on_unique_keys'
  end
end
