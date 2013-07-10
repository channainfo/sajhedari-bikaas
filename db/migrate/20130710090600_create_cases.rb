class CreateCases < ActiveRecord::Migration
  def change
    create_table :cases do |t|
      t.string :message
      t.references :conflict_type, index: true
      t.references :conflict_intensity, index: true
      t.references :conflict_state, index: true
      t.references :location, index: true
      t.string :user_id
      t.string :site_id

      t.timestamps
    end
  end
end
