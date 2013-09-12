class AddIsSuccessToMessage < ActiveRecord::Migration
  def change
  	add_column :messages, :is_success, :boolean
  end
end
