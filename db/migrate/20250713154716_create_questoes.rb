class CreateQuestoes < ActiveRecord::Migration[7.1]
  def change
    create_table :questoes do |t|
      t.text :enunciado, null: false
      t.string :tipo, null: false
      t.boolean :obrigatoria, default: false
      t.string :opcoes
      t.references :template, null: false, foreign_key: true

      t.timestamps
    end

    add_index :questoes, [:template_id, :created_at]
  end
end
