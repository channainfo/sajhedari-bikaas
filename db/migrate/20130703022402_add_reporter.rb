class AddReporter < ActiveRecord::Migration
  def change
  	create_table :reporters do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :sex
      t.string :cast
      t.string :ethnicity
      t.string :address

      t.timestamps
    end
  end
end
