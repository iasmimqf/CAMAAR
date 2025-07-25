class AddOcupacaoToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_column :usuarios, :ocupacao, :string
  end
end
