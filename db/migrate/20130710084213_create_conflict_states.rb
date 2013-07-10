class CreateConflictStates < ActiveRecord::Migration
  def change
    create_table :conflict_states do |t|
      t.string :name

      t.timestamps
    end
  end
end
