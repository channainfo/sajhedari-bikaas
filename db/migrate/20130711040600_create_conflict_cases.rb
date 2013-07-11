class CreateConflictCases < ActiveRecord::Migration
  def change
    create_table :conflict_cases do |t|
      t.string :case_message
      t.references :conflict_type, index: true
      t.references :conflict_intensity, index: true
      t.references :conflict_state, index: true
      t.references :location, index: true
      t.integer :site_id
      t.integer :user_id

      t.timestamps
    end
  end
end
