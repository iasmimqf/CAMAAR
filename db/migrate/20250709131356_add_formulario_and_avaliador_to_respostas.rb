class AddFormularioAndAvaliadorToRespostas < ActiveRecord::Migration[8.0]
  def change
    add_reference :respostas, :formulario, null: false, foreign_key: true
    add_reference :respostas, :avaliador, null: false, foreign_key: { to_table: :usuarios }
  end
end
