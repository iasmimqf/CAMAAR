class AddProfessorToTurmas < ActiveRecord::Migration[7.1]
  def change
add_reference :turmas, :professor, null: false, foreign_key: { to_table: :usuarios }  end
end
