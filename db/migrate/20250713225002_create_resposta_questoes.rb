class CreateRespostaQuestoes < ActiveRecord::Migration[7.1]
  def change
    create_table :resposta_questoes do |t|
      t.references :resposta_formulario, null: false, foreign_key: true
      t.references :questao, null: false, foreign_key: { to_table: :questoes }
      t.integer :valor_resposta
      t.text :texto_resposta
      t.timestamps
    end

    add_index :resposta_questoes, [ :resposta_formulario_id, :questao_id ], unique: true
  end
end
