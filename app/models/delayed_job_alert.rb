class DelayedJobAlert < ActiveRecord::Base
	belongs_to :delayed_job
	belongs_to :alert

	attr_accessible :delayed_job_id
	attr_accessible :alerts_id
end
