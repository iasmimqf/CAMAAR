class AddIdToDisciplinas < ActiveRecord::Migration[7.1]
  def change
    drop_table :disciplinas, if_exists: true
    create_table :disciplinas do |t|
      # A chave primária 'id' agora será criada por padrão
      t.string "codigo", null: false
      t.string "nome", null: false
      t.text   "descricao"

      t.timestamps
    end
    # Adiciona o índice para garantir que cada 'codigo' seja único
    add_index :disciplinas, :codigo, unique: true

  end
end
