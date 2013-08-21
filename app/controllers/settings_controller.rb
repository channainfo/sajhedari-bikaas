class SettingsController < ApplicationController  
  before_filter :authenticate_user!

  def index
    @setting = Setting.first
  end

  def update
  	@setting = Setting.find(params[:id])
  	if(@setting.update_attributes(params[:setting]))
      system 'bundle exec whenever --update-crontab store'
  		flash[:notice] = "You have successfully saved setting configuration."
  		redirect_to settings_path
  	else
  		render :edit
  	end    
  end

  def show
  	
  end

end