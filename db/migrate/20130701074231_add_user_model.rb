class AddUserModel < ActiveRecord::Migration
  def change
  	create_table :users do |t|
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :sex
      t.string :cast
      t.string :ethnicity
      t.string :address
      t.string :email
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token

      t.timestamps
    end
  end
end
