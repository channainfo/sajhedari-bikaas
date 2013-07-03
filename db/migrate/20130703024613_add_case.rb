class AddCase < ActiveRecord::Migration
  def change
  	create_table :cases do |t|
      t.string  :type
      t.string  :intensity
      t.integer :location_id, references: :locations
      t.string  :state_of_conflict
      t.integer :user_id, references: :users

      t.timestamps
    end
  end
end
