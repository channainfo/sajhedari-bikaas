class HomeController < ApplicationController  
  before_filter :authenticate_user!

  def index
    if current_user && !params[:explicit]
      if mobile_device?
        redirect_to mobile_conflict_cases_path
      else
        redirect_to conflict_cases_path
      end
    else
      if mobile_device?
        redirect_to new_user_sessions_path 
      end
    end
  end
end