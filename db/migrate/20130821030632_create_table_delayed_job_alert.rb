class CreateTableDelayedJobAlert < ActiveRecord::Migration
	def change
		create_table :delayed_job_alerts do |t|
			t.references :delayed_job
			t.references :alerts
		  t.timestamps
		end
	end
end
