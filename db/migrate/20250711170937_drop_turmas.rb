class DropTurmas < ActiveRecord::Migration[8.0]
  def up
    drop_table :turmas
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
