class UserMailer < ActionMailer::Base
  NO_REPLY = Setting.first.email_send
  default :from => NO_REPLY

  def notify_members(user, message)
    @message = message
    mail :to => user.email, :subject => "Sajhedari Bikaas Alert", :from => UserMailer::NO_REPLY
  end
end
