class AddMessageIdAndRemoveCaseMessageToConflictCase < ActiveRecord::Migration
  def up
  	add_column :conflict_cases, :message_id, :integer, references: :messages
  	remove_column :conflict_cases, :case_message
  end

  def down
  	remove_column :conflict_cases, :message_id
  	add_column :conflict_cases, :case_message, :string
  end
end
