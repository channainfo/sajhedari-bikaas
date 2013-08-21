class UserMailer < ActionMailer::Base
  NO_REPLY = "noreply@resourcemap.instedd.org"
  default :from => NO_REPLY

  def notify_members(user, message)
    @message = message
    mail :to => user.email, :subject => "Aggregate Threshold Alert", :from => UserMailer::NO_REPLY
  end
end
