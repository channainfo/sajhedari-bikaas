class AddCastEthnicityToUserAndReporter < ActiveRecord::Migration
  def up
  	add_column :users, :cast_ethnicity, :string
  	add_column :reporters, :cast_ethnicity, :string
  end

  def down
  	remove_column :users, :cast_ethnicity
  	remove_column :reporters, :cast_ethnicity
  end
end
