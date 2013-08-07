class RemoveCastEthnicityFromUserAndReporter < ActiveRecord::Migration
  def up
  	remove_column :users, :ethnicity
  	remove_column :users, :cast
  	remove_column :reporters, :ethnicity
  	remove_column :reporters, :cast
  end

  def down
  	add_column :users, :ethnicity, :string
  	add_column :users, :cast, :string
  	add_column :reporters, :ethnicity, :string
  	add_column :reporters, :cast, :string
  end
end
