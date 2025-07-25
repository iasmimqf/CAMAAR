class AddPrazoToFormularios < ActiveRecord::Migration[7.1]
  def change
    add_column :formularios, :prazo, :datetime
  end
end
