class AddFormacaoToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_column :usuarios, :formacao, :string
  end
end
