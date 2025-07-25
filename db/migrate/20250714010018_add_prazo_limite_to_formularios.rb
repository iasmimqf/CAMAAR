class AddPrazoLimiteToFormularios < ActiveRecord::Migration[7.1]
  def change
    add_column :formularios, :prazo_limite, :date
  end
end
