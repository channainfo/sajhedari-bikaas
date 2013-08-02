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
      flash[:notice] = "You have successfully created location #{@location.name}."      
      redirect_to locations_path
    else
      render :new
    end
  end

  def edit
    @location = Location.find(params[:id])
    if(@location.is_updated)
      flash[:error] = "Location #{@location.name} is marked as updated. Please approve the update before make another change."
      redirect_to locations_path
    end
    if(@location.is_deleted)
      flash[:error] = "Location #{@location.name} is marked as deleted. Please cancel delete before make another change."
      redirect_to locations_path
    end

  end

  def update
    @location = Location.find(params[:id])
    if @location.is_updated       
      unless @location.backup.user.id == current_user.id
        flash[:error] = "Location #{@location.name} is marked as updated please click Approve to update to confirm update location."
        redirect_to locations_path
      else
        flash[:error] = "Failed to update location #{@location.name}. Please try again later."
        redirect_to locations_path
      end

    else
      flash[:notice] = "#{@location.name} is mark as updated."
      Backup.create!(:entity_id => @location.id, :data => params[:location].to_json, :category => Location.get_category, :user_id => current_user.id)
      @location.is_updated = true
      @location.save
      redirect_to locations_path
    end
    
    
  end

  def destroy
    @location = Location.find(params[:id])
    if @location.is_deleted 
      unless @location.backup.user.id == current_user.id
        flash[:error] = "Location #{@location.name} is marked as deleted please click Approve to delete to confirm delete location."
        redirect_to locations_path
      else
        flash[:error] = "Failed to delete location #{@location.name}. Please try again later."
        redirect_to locations_path
      end
    else
      flash[:notice] = "#{@location.name} is mark as deleted."
      Backup.create!(:entity_id => @location.id, :data => @location.to_json, :category => Location.get_category, :user_id => current_user.id)
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
        flash[:notice] = "You have successfully imported #{rows[:success]} locations to your system with #{rows[:failed]} failed."
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

  def cancel_delete
    @location = Location.find(params[:id])
    if(@location.is_deleted and @location.backup)
      flash[:notice] = "#{@location.name} is mark as undeleted."
      @location.backup.destroy
      @location.is_deleted = false
      @location.save
      redirect_to locations_path
    else
      redirect_to locations_path
    end
  end

  def cancel_update
    @location = Location.find(params[:id])
    if(@location.is_updated and @location.backup)
      flash[:notice] = "#{@location.name} is mark as not updated."
      @location.backup.destroy
      @location.is_updated = false
      @location.save
      redirect_to locations_path
    else
      redirect_to locations_path
    end
  end

  def approve_delete
    @location = Location.find(params[:id])
    if(@location and @location.is_deleted and @location.backup and @location.backup.user.id != current_user.id)
      @location.destroy!
      @location.backup.destroy!
      flash[:notice] = "You have successfully deleted #{@location.name}."
      redirect_to locations_path
    else
      flash[:error] = "Process delete #{@location.name} failed."
      redirect_to locations_path
    end
  end

  def approve_update
    @location = Location.find(params[:id])
    if(@location and @location.is_updated and @location.backup and @location.backup.user.id != current_user.id)
      conflict_cases = ConflictCase.where(:location_id => params[:id])
      site_ids = Location.generate_site_id conflict_cases
      user_emails = Location.generate_user_email conflict_cases
      if @location.update_to_resourcemap(site_ids, user_emails)
        if(@location.update_attributes!(@location.backup.data))        
          flash[:notice] = "You have successfully updated location #{@location.name}."
          @location.backup.destroy!
          @location.is_updated = false
          @location.save
          redirect_to locations_path
        else
          redirect_to locations_path
        end 
      else
        flash[:error] = "Failed to update location on resource map application. Please try again later."
        redirect_to locations_path
      end     
    else
      flash[:error] = "Process update #{@location.name} failed."
      redirect_to locations_path
    end
  end

  def apply_update_form
    @location = Location.find(params[:id])
    if(@location and @location.is_updated and @location.backup and @location.backup.user.id != current_user.id)
      conflict_cases = ConflictCase.where(:location_id => params[:id])
      site_ids = Location.generate_site_id conflict_cases
      user_emails = Location.generate_user_email conflict_cases
      if @location.update_to_resourcemap(site_ids, user_emails)
        if(@location.update_attributes!(params[:location]))        
          flash[:notice] = "You have successfully updated location #{@location.name}."
          @location.backup.destroy!
          @location.is_updated = false
          @location.save
          redirect_to locations_path
        else
          redirect_to locations_path
        end 
      else
        flash[:error] = "Failed to update location on resource map application. Please try again later."
        redirect_to locations_path
      end     
    else
      flash[:error] = "Process update #{@location.name} failed."
      redirect_to locations_path
    end
  end

  def view_difference
    @base = Location.find(params[:id])
  end
end