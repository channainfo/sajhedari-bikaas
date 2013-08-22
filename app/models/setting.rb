class Setting < ActiveRecord::Base    
  validates_presence_of :interval_alert

  attr_accessible :interval_alert
  attr_accessible :message_success
  attr_accessible :message_invalid
  attr_accessible :message_unknown
  attr_accessible :message_invalid_sender
  attr_accessible :message_duplicate
  attr_accessible :message_failed
  attr_accessible :email_send

end