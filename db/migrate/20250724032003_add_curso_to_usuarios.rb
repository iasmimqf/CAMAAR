class AddCursoToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_column :usuarios, :curso, :string
  end
end
