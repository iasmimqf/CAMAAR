class AddCriadorToFormularios < ActiveRecord::Migration[8.0]
  def change
    add_reference :formularios, :criador, null: false, foreign_key: { to_table: :usuarios }
  end
end
