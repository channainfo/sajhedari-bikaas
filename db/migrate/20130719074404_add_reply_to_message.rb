class AddReplyToMessage < ActiveRecord::Migration
  def change
  	add_column :messages, :reply, :text
  end
end
