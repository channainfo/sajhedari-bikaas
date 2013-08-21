class AddSetting < ActiveRecord::Migration
  def change
  	create_table :settings do |t|

      t.integer :interval_alert
      t.text 	:message_success
      t.text	:message_invalid
      t.text	:message_unknown
      t.text	:message_invalid_sender
      t.text  :message_duplicate
      t.text  :message_failed

      t.timestamps
    end
  end
end
