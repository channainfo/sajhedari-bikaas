class AddContactAlert < ActiveRecord::Migration
  def up
  	add_column :alerts, :phone_contacts, :text
  	add_column :alerts, :email_contacts, :text
  end

  def down
  	remove_column :alerts, :phone_contacts
  	remove_column :alerts, :email_contacts
  end
end
