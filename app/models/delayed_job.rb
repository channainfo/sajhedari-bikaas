class DelayedJob < ActiveRecord::Base
	has_many :delayed_job_alerts, :dependent => :destroy
end