# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever



require File.expand_path('../environment', __FILE__)
Setting.first.reload
alert_interval = Setting.first.interval_alert || 24
every alert_interval.to_i.hours do
  runner 'Alert.process_schedule'
end


# every :day , :at => "09:49 am" do		
#    runner "Alert.process_schedule", :environment => 'development'
# end