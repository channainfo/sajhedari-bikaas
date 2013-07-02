class HomeController < ApplicationController  
  before_filter :authenticate_user!

  def index
    if current_user && !params[:explicit]
      if mobile_device?
        p "Helllo"
        # redirect_to mobile_collections_path 
      else
        p "Desktop"
        # redirect_to collections_path
      end
    else
      if mobile_device?
        P "Mobile"
        # redirect_to new_user_session_path 
      end
    end
  end
end