class AddConflictTypeAndConflictCodeAsConfiguration < ActiveRecord::Migration
  def change
  	add_column :settings, :conflict_type_code, :string
  	add_column :settings, :conflict_location_code, :string
  end
end
