class LocationsController < ApplicationController  
  before_filter :authenticate_user!

  def index
    @locations = Location.all.paginate(:page => params[:page], :per_page => 3)
  end

  def show
  	
  end

  def new
  	@location = Location.new()
  end

  def create
    @location = Location.new(params[:location])
  	if @location.save
      flash[:notice] = "You have successfully create location #{@location.name}."      
      redirect_to locations_path
    else
      render :new
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])
    conflict_cases = ConflictCase.where(:location_id => params[:id])
    site_ids = Location.generate_site_id conflict_cases
    user_emails = Location.generate_user_email conflict_cases

    if(@location.update_attributes(params[:location]))
      @location.update_to_resourcemap site_ids, user_emails
      flash[:notice] = "You have successfully update location #{@location.name}."
      redirect_to locations_path
    else
      render :edit
    end
  end

  def destroy
    @location = Location.find(params[:id])
    if @location.destroy
      flash[:notice] = "You have successfully delete location #{@location.name}."
      redirect_to locations_path
    else
      flash[:error] = "Failed to delete location #{@location.name}. Please try again later."
      redirect_to locations_path
    end
  end
end