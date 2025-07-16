class AddAdminToUsuarios < ActiveRecord::Migration[7.1]
class AddAdminToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_column :usuarios, :admin, :boolean
  end
end
