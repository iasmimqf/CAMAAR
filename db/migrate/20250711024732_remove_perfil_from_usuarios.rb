class RemovePerfilFromUsuarios < ActiveRecord::Migration[8.0]
  def change
    remove_column :usuarios, :perfil, :string
  end
end
