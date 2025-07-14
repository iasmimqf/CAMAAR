class CreateRespostaFormularios < ActiveRecord::Migration[7.1]
  def change
    create_table :resposta_formularios do |t|
      t.references :formulario, null: false, foreign_key: true
      t.references :respondente, null: false, foreign_key: { to_table: :usuarios }
      t.timestamps
    end
    
    add_index :resposta_formularios, [:formulario_id, :respondente_id], unique: true
  end
end
