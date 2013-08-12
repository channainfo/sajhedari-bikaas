class AddAlert < ActiveRecord::Migration
  def change
  	create_table :alerts do |t|

      t.text :condition
      t.string :name
      t.integer :last_days
      t.integer :total
      t.integer :priority

      t.timestamps
    end
  end
end
