class Alert < ActiveRecord::Base    
  validates_presence_of :name
  validates_presence_of :last_days
  validates_presence_of :total
  validates_presence_of :condition
  validates_presence_of :message
  validates_numericality_of :last_days, :greater_than_or_equal_to => 0
  validates_numericality_of :total, :greater_than => 0
  attr_accessible :last_days
  attr_accessible :total
  attr_accessible :condition
  attr_accessible :message
  attr_accessible :phone_contacts
  attr_accessible :email_contacts

  has_many :delayed_job_alerts

  def full_description
  	fields = ConflictCase.get_fields
  	condition_list = []
  	JSON.parse(self.condition).each do |key,value|
  		fields.each do |f|
  			if f["code"] == key
          f["options"].each do |op|
            if(op["code"] == value)
  				    condition_list.push(f["name"].to_s + " is equal to " + op["label"])
            end
          end
  			end
  		end
  	end
  	condition_list.join(" and ")
  end

  def self.process_schedule    
    Alert.all.each do |a|
      a.send_alert
    end
  end

  def send_alert
    fields = ConflictCase.get_fields()
    start_date = DateTime.now - self.last_days.day
    end_date = DateTime.now
    sites = ConflictCase.get_all_sites_from_resource_map_by_period(start_date, end_date)
    conflict_cases = ConflictCase.transform(sites, fields)
    count = 0
    conflict_cases.each do |conflict|
      if conflict.meet_alert?(JSON.parse(self.condition))
        count = count + 1
      end
    end
    if count > self.total
      JSON.parse(self.email_contacts).each do |id|
        user = User.find(id)
        if (user.email)
          Delayed::Job.enqueue(EmailJob.new(user, self.message), 1)
          addJobToDelayedJobAlert
        end
      end
      JSON.parse(self.phone_contacts).each do |id|
        user = User.find(id)
        if (user.phone_number)
          Delayed::Job.enqueue(SmsJob.new(user.phone_number, NuntiumConfig["channel"] , self.message), 1)
          addJobToDelayedJobAlert
        end
      end
    end
  end

  def addJobToDelayedJobAlert
    DelayedJobAlert.create!(:delayed_job_id => Delayed::Job.last.id, :alerts_id => self.id)
  end

end