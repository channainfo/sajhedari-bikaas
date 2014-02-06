class AddPropertiesToConflictCase < ActiveRecord::Migration
  def change
  	add_column :conflict_cases, :properties, :text
  end
end
