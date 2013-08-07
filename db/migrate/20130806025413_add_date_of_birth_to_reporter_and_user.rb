class AddDateOfBirthToReporterAndUser < ActiveRecord::Migration
  def up
  	add_column :users, :date_of_birth, :date
  	add_column :reporters, :date_of_birth, :date
  end

  def down
  	remove_column :users, :date_of_birth
  	remove_column :reporters, :date_of_birth
  end
end
