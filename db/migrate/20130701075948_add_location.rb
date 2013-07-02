class AddLocation < ActiveRecord::Migration
  def change
  	create_table :locations do |t|
      t.string :name
      t.string :code
      t.decimal :lat, :precision => 10, :scale => 6
      t.decimal :lng, :precision => 10, :scale => 6
      

      t.timestamps
    end
  end
end
