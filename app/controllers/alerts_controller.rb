class AlertsController < ApplicationController
	before_filter :authenticate_user!
	def index
		@alerts = Alert.all.paginate(:page => params[:page], :per_page => 10)
		@fields = ConflictCase.get_fields
		unless @fields
			flash[:error] = "Failed to connect to resourcemap."
			@fields = []
		end
	end

	def new
		@fields = ConflictCase.get_fields
		@alert = Alert.new()
		@admin = User.all()
	end

	def create
		@alert = Alert.new(params[:alert])
		@alert.name = params["alert"]["name"]
		@alert.condition = generate_condition(params[:type], params[:item]);
		@alert.phone_contacts = params[:phone]? params[:phone].to_json : {}.to_json
		@alert.email_contacts = params[:email]? params[:email].to_json : {}.to_json
	  	if @alert.save
			flash[:notice] = "You have successfully created alert #{@alert.name}."      
			redirect_to alerts_path
	    else
	    	@fields = ConflictCase.get_fields	
			@admin = User.all()	
	    	render :new
	    end
	end

	def update
		@alert = Alert.find(params[:id])
		params["alert"]["condition"] = generate_condition(params[:type], params[:item]);
		params["alert"]["phone_contacts"] = params[:phone]? params[:phone].to_json : {}.to_json
		params["alert"]["email_contacts"] = params[:email]? params[:email].to_json : {}.to_json
		@alert.phone_contacts = params["alert"]["phone_contacts"]
		@alert.email_contacts = params["alert"]["email_contacts"]
		@alert.name = params["alert"]["name"]
		@alert.condition = params["alert"]["condition"]
		@alert.total = params["alert"]["total"]
		@alert.last_days = params["alert"]["last_days"]
		@alert.message = params["alert"]["message"]
	  	if @alert.save
			flash[:notice] = "You have successfully updated alert #{@alert.name}."      
			redirect_to alerts_path
	    else
	    	@admin = User.all()
	    	@fields = ConflictCase.get_fields
	    	render :edit
	    end
	end

	def generate_condition types, items
		condition_obj = {}
		types.each_with_index {|k,i| condition_obj[k] = items[i] }
		condition_obj.to_json
	end

	def edit
		@alert = Alert.find(params[:id])
		@fields = ConflictCase.get_fields	
		@admin = User.all()	
	end

	def destroy
		@alert = Alert.find(params[:id])
		if @alert.destroy      
			flash[:notice] = "You have successfully deleted alert #{@alert.name}."
			redirect_to alerts_path
		else
			flash[:error] = "Failed to delete alert #{@alert.name}. Please try again later."
			redirect_to alerts_path
		end
	end
end