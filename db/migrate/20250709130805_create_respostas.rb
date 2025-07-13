class CreateRespostas < ActiveRecord::Migration[7.1]
  def change
    create_table :respostas do |t|
      t.datetime :dataDeSubmissao
      t.text :respostasJSON

      t.timestamps
    end
  end
end
