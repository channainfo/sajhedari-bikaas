class AddRoleToUser < ActiveRecord::Migration
  def change
  	add_column :users, :role_id, :integer, references: :roles
  end
end
