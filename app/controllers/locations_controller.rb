class LocationsController < ApplicationController  
  before_filter :authenticate_user!

  def index
    @locations = Location.all.paginate(:page => params[:page], :per_page => 10)
  end

  def show
  	
  end

  def new
  	@location = Location.new()
  end

  def create
    @location = Location.new(params[:location])
  	if @location.save
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
    if(@location.update_attributes(params[:location]))
      redirect_to locations_path
    else
      render :edit
    end
  end

  def destroy
    Location.find(params[:id]).destroy
    redirect_to locations_path
  end
end