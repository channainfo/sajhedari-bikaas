class RemoveUserIDandAddReporterIdFromConflictCase < ActiveRecord::Migration
  def change
  	add_column :conflict_cases, :reporter_id, :integer, references: :reporters
  	remove_column :conflict_cases, :user_id
  end
end
