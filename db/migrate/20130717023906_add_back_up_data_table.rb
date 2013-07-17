class AddBackUpDataTable < ActiveRecord::Migration
  def change
  	create_table :backups do |t|
      t.integer :entity_id
      t.text 	:data
      t.string 	:category
      t.references :user

      t.timestamps
    end
  end
end
