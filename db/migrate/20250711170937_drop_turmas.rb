class DropTurmas < ActiveRecord::Migration[7.1]
  def up
    drop_table :turmas
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
