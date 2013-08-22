class AddEmailSendSetting < ActiveRecord::Migration
  def change
  	add_column :settings, :email_send, :string
  end
end
