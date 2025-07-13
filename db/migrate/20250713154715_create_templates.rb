class CreateTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :templates do |t|
      t.string :titulo, null: false
      t.references :criador, null: false, foreign_key: { to_table: :usuarios }

      t.timestamps
    end

    add_index :templates, :titulo, unique: true
  end
end
