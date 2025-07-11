class AddAdminToUsuarios < ActiveRecord::Migration[8.0]
  def change
    add_column :usuarios, :admin, :boolean
  end
end
