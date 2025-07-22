class CreateJoinTableFormulariosTurmas < ActiveRecord::Migration[7.1]
  def change
    create_join_table :formularios, :turmas do |t|
      t.index [:formulario_id, :turma_id]
      t.index [:turma_id, :formulario_id]
    end
  end
end
