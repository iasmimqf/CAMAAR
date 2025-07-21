class RemovePerfilFromUsuarios < ActiveRecord::Migration[7.1]
  def change
    remove_column :usuarios, :perfil, :string
  end
end
