class AddMessageToAlert < ActiveRecord::Migration
  def up
  	add_column :alerts, :message, :text
  end

  def down
  	remove_column :alerts, :message
  end
end
