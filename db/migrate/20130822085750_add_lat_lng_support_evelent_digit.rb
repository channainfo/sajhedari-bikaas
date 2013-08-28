class AddLatLngSupportEvelentDigit < ActiveRecord::Migration
	def up
		remove_column :locations, :lat
		remove_column :locations, :lng
		add_column :locations, :lat, :decimal, :precision => 15, :scale => 11
		add_column :locations, :lng, :decimal, :precision => 15, :scale => 11
			   
	end

	def down
		remove_column :locations, :lat
		remove_column :locations, :lng
		add_column :locations, :lat, :decimal, :precision => 10, :scale => 6
		add_column :locations, :lng, :decimal, :precision => 10, :scale => 6
	end
end
