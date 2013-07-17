class AddBackUpDataTable < ActiveRecord::Migration
  def change
  	create_table :backup do |t|
      t.integer :entity_id
      t.text 	:data
      t.string 	:type

      t.timestamps
    end
  end
end
