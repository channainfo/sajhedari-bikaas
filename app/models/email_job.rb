class EmailJob
	def initialize user, message
		@user = user
		@message = message
	end

	def perform
		UserMailer.notify_members(@user, @message).deliver
	end

	def success job
		alert_job = DelayedJobAlert.find_by_delayed_job_id(job.id)
		if (alert_job)
			alert_job.destroy
		end
	end
end
