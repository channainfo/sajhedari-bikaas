class AddIsDeletedAndIsUpdatedToLocation < ActiveRecord::Migration
  def change
  	add_column :locations, :is_deleted, :boolean, :default => false
  	add_column :locations, :is_updated, :boolean, :default => false
  end
end
