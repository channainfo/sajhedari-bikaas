class SmsJob
  def initialize phone_number, channel, message
    @phone_number = phone_number
    @channel = channel
		@message = message
  end

  def perform
    Sms.send do |sms|
      sms.to = @phone_number
      sms.body = @message
      sms.channel = @channel
    end
  end

  def success job
    alert_job = DelayedJobAlert.find_by_delayed_job_id(job.id)
    if (alert_job)
      alert_job.destroy
    end   
  end
end 
