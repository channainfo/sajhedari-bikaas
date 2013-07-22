class AddIsDeletedAndIsUpdatedToConflictCase < ActiveRecord::Migration
  def change
  	add_column :conflict_cases, :is_deleted, :boolean, :default => false
  	add_column :conflict_cases, :is_updated, :boolean, :default => false
  end
end
