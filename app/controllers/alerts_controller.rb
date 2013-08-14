class AlertsController < ApplicationController
	before_filter :authenticate_user!
	def index
		@alerts = Alert.all.paginate(:page => params[:page], :per_page => 10)
		@fields = ConflictCase.get_fields
	end

	def new
		@fields = ConflictCase.get_fields
		@alert = Alert.new()
	end

	def create
		@alert = Alert.new(params[:alert])
		@alert.condition = generate_condition(params[:type], params[:item]);
	  	if @alert.save
			flash[:notice] = "You have successfully created alert #{@alert.name}."      
			redirect_to alerts_path
	    else
	      render :new
	    end
	end

	def generate_condition types, items
		condition_obj = {}
		types.each_with_index {|k,i| condition_obj[k] = items[i] }
		condition_obj.to_json
	end
end