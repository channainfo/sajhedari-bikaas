class AddEncryptedPasswordToUser < ActiveRecord::Migration
  def change
  	add_column :users, :encrypted_password, :string
  	remove_column :users, :crypted_password
  end
end
