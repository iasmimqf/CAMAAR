class AddTemplateToFormularios < ActiveRecord::Migration[7.1]
  def change
    add_reference :formularios, :template, foreign_key: true, null: true
  end
end
