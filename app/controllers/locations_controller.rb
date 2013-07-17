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

    if(@location.update_attributes!(params[:location]))
      @location.update_to_resourcemap site_ids, user_emails
      flash[:notice] = "You have successfully update location #{@location.name}."
      redirect_to locations_path
    else
      render :edit
    end
  end

  def destroy
    @location = Location.find(params[:id])
    if @location.is_deleted 
      if @location.destroy
        flash[:notice] = "You have successfully delete location #{@location.name}."
        redirect_to locations_path
      else
        flash[:error] = "Failed to delete location #{@location.name}. Please try again later."
        redirect_to locations_path
      end
    else
      flash[:notice] = "#{@location.name} is mark as deleted."
      @location.is_deleted = true
      @location.save
      redirect_to locations_path
    end
  end

  def import
    
  end

  def import_process
    max_file_size = 512000 
    datas = {}
    errors = {}
    redundant_list = []
    if(params["location"]["file_import"])
      file_obj = params["location"]["file_import"]
      file_size = File.size(file_obj.path)
      errors = { "data" => file_size, "error_type" => "File over limited size" } if file_size > max_file_size
      filename = file_obj.original_filename
      if(!filename.end_with? ".csv" and errors.empty? )
        errors = { "data" =>filename ,"error_type" => "File is not csv format." }  
      end

      if(!Import::validate_header?(file_obj.path) and errors.empty?)
        error_type = Import::get_error_type
        errors = { "data" =>filename ,"error_type" => error_type}
      end 

      if(errors.empty?)
        rows = Import::process_import file_obj.path
        flash[:notice] = "You have successfully import #{rows[:success]} locations to your system with #{rows[:failed]} failed."
        redirect_to locations_path
      else
        flash[:error] = "Process import failed. #{errors['error_type']}"
        render :import
      end
    end
  end

  def download_location_template
    respond_to do |format|
      format.json  { render :json => result }
      format.csv {
        content = "name,code,lat,lng"
        render :text => content
      }
    end
  end
end