class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper :all
  protect_from_forgery
  layout :layout_by_resource 
  before_filter :prepare_resourcemap_url

  private

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    #request.format = :mobile if mobile_device?
  end

  def layout_by_resource
    if devise_controller? && resource_name == :user && action_name == 'new'
      'devise'
    else
      'application'
    end
  end

  def current_user_or_guest
    if user_signed_in?
      return if !current_user.try(:is_guest)
    end

    if current_user.try(:is_login)
      current_user.is_login = false
      current_user.save!
    else
      sign_out :user
    end
  end

  def after_sign_in_path_for(resource)
    if mobile_device?
       stored_location_for(resource) || mobile_locations_path
    else
       stored_location_for(resource) || locations_path
    end
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
  end

  def is_super_admin? user
    user.role.name == "Super Admin"
  end

  def is_admin? user
    user.role.name == "Admin"
  end

  def prepare_resourcemap_url
    @rm = load_resource_map
  end

  def load_resource_map
    YAML.load_file File.expand_path(Rails.root + "config/resourcemap.yml", __FILE__)
  end
end
