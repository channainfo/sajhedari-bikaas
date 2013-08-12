class AlertsController < ApplicationController
	before_filter :authenticate_user!
	def index
		@alerts = Alert.all.paginate(:page => params[:page], :per_page => 10)
	end

	def new
		@fields = ConflictCase.get_fields
		@alert = Alert.new()
	end
end