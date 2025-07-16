class CreateFormularios < ActiveRecord::Migration[8.0]
  def change
    create_table :formularios do |t|
      t.string :titulo
      t.boolean :ehTemplate
      t.string :status
      t.text :estruturaJSON
      t.datetime :dataDeExpiracao

      t.timestamps
    end
  end
end
