class CreateTurmas < ActiveRecord::Migration[8.0]
  def change
    create_table :turmas do |t|
      t.string :nomeDaTurma
      t.string :semestre
      t.boolean :ativo
      t.text :descricao

      t.timestamps
    end
  end
end
