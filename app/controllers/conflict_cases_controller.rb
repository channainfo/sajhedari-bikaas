
require 'will_paginate/array'
class ConflictCasesController < ApplicationController  
  before_filter :authenticate_user!

  def index
    @fields = ConflictCase.get_fields
    @from = DateTime.strptime(params[:from], "%m-%d-%Y").to_date.to_s if params[:from]
    @to = DateTime.strptime(params[:to], "%m-%d-%Y").to_date.to_s if params[:to]
    unless @fields
      flash[:error] = "Failed to connect to resourcemap."
      @fields = []
      @conflict_cases = []
      @paging = [].paginate(:page => 1, :per_page => PageSize)
    else
      page  = params[:page]? params[:page]:1
      sites = ConflictCase.get_paging_sites_from_resource_map(PageSize, PageSize*(page.to_i - 1), @from, @to)
      @conflict_cases = ConflictCase.transform(sites["sites"], @fields)
      @paging = ([1] * sites["total"].to_i).paginate(:page => page, :per_page => PageSize)
    end
    @from = params[:from]
    @to = params[:to]
  end

  def extract_data_sources
    fields = ConflictCase.get_fields
    sites   = ConflictCase.all_from_resource_map
    conflict_cases = ConflictCase.transform(sites, fields)  
  end

  def export_file type
    date_str = DateTime.now.strftime('%Y-%m-%d %H-%M-%S')
    "conflict-#{date_str}.#{type}"
  end

  def export_dir 
    "#{Rails.root}/public/data/export/"
  end

  def export_as_kml
    file = export_file 'kml'
    kml_file = export_dir + file

    exporter = Exporter.new extract_data_sources
    exporter.to_kml_file kml_file

    send_file( kml_file, :filename      =>  file ,
                         :type          =>  'application/vnd.google-earth.kml+xml',
                         :disposition   =>  'attachment',
                         :streaming     =>  true,
                         :buffer_size   =>  '4096')
    # File.delete kml_file

  end

  def export_as_shp
    file     = export_file 'zip'
    zip_file = export_dir + file

    exporter = Exporter.new extract_data_sources
    exporter.to_sh_zip zip_file

    send_file( zip_file, :filename      =>  file ,
                         :type          =>  'application/x-gzip',
                         :disposition   =>  'attachment',
                         :streaming     =>  true,
                         :buffer_size   =>  '4096')

    # File.delete zip_file

  end

  def show
  	
  end

  def new
    @locations = Location.all
    @reporters = Reporter.all
    @fields = ConflictCase.get_fields
  	@conflict_case = ConflictCase.new()
  end

  def create
    @conflict_case = ConflictCase.new(params[:conflict_case])
    site = @conflict_case.save_case_to_resource_map
    if site
      @conflict_case.site_id = site["id"]
    	if @conflict_case.save
        flash[:notice] = "You have successfully created conflict case #{@conflict_case.location.name}."      
        redirect_to conflict_cases_path
      else
        render :new
      end
    else
      flash[:error] = "Failed to create case on resource map application. Please try again later."
      render :new
    end
  end

  def edit
    @locations = Location.all
    @fields = ConflictCase.get_fields
    conflict = ConflictCase.find(params[:id])
    @conflict_case = ConflictCase.convertToConflictCase(conflict.get_conflict_from_resource_map, @fields)
  end

  def update
    @conflict_case = ConflictCase.find(params[:id])
    if @conflict_case.is_updated       
      unless @conflict_case.backup.user.id == current_user.id
        flash[:error] = "Case #{@conflict_case.location.name} is marked as updated please click Approve to update to confirm update location."
        redirect_to conflict_cases_path
      else
        flash[:error] = "Failed to update case #{@conflict_case.location.name}. Please try again later."
        redirect_to conflict_cases_path
      end

    else
      flash[:notice] = "#{@conflict_case.location.name} is marked as updated."
      Backup.create!(:entity_id => @conflict_case.id, :data => params[:conflict_case].to_json, :category => ConflictCase.get_category, :user_id => current_user.id)
      @conflict_case.is_updated = true
      @conflict_case.save
      redirect_to conflict_cases_path
    end
  end

  def destroy
    @conflict_case = ConflictCase.find(params[:id])
    if @conflict_case.is_deleted 
      unless @conflict_case.backup.user.id == current_user.id
        flash[:error] = "Conflict Case is marked as deleted please click Approve to delete to confirm delete location."
        redirect_to conflict_cases_path
      else
        flash[:error] = "Failed to delete Conflict Case. Please try again later."
        redirect_to conflict_cases_path
      end
    else
      flash[:notice] = "Conflict Case is marked as deleted."
      Backup.create!(:entity_id => @conflict_case.id, :data => @conflict_case.to_json, :category => ConflictCase.get_category, :user_id => current_user.id)
      @conflict_case.is_deleted = true
      @conflict_case.save
      redirect_to conflict_cases_path
    end
  end

  def cancel_delete
    @conflict_case = ConflictCase.find(params[:id])
    if(@conflict_case.is_deleted and @conflict_case.backup)
      flash[:notice] = "#{@conflict_case.location.name} is marked as undeleted."
      @conflict_case.backup.destroy
      @conflict_case.is_deleted = false
      @conflict_case.save
      redirect_to conflict_cases_path
    else
      redirect_to conflict_cases_path
    end
  end

  def cancel_update
    @conflict_case = ConflictCase.find(params[:id])
    if(@conflict_case.is_updated and @conflict_case.backup)
      flash[:notice] = "#{@conflict_case.location.name} is marked as not updated."
      @conflict_case.backup.destroy
      @conflict_case.is_updated = false
      @conflict_case.save
      redirect_to conflict_cases_path
    else
      redirect_to conflict_cases_path
    end
  end

  def approve_delete
    @conflict_case = ConflictCase.find(params[:id])
    site = @conflict_case.destroy_case_from_resource_map
    if(@conflict_case and @conflict_case.is_deleted and @conflict_case.backup and @conflict_case.backup.user.id != current_user.id and site)
      @conflict_case.destroy!
      @conflict_case.backup.destroy!
      flash[:notice] = "You have successfully deleted #{@conflict_case.location.name}."
      redirect_to conflict_cases_path
    else
      flash[:error] = "Process delete #{@conflict_case.location.name} failed."
      redirect_to conflict_cases_path
    end
  end

  def apply_update_form
    @conflict_case = ConflictCase.find(params[:id])
    if(@conflict_case and @conflict_case.is_updated and @conflict_case.backup and @conflict_case.backup.user.id != current_user.id)
      if @conflict_case.update_to_resource_map_with_form params[:conflict_case]
        if(@conflict_case.update_attributes(:location_id => params["conflict_case"]["location_id"]))
          flash[:notice] = "You have successfully updated conflict case #{@conflict_case.location.name}."
          @conflict_case.backup.destroy!
          @conflict_case.is_updated = false
          @conflict_case.save
          redirect_to conflict_cases_path        
        else
          flash[:error] = "Failed to update conflict location. Please try again later."
          redirect_to conflict_cases_path
        end
      else 
        @conflict_types = ConflictType.all
        @conflict_states = ConflictState.all
        @conflict_intensities = ConflictIntensity.all
        flash[:error] = "Failed to update case on resource map application. Please try again later."
        redirect_to conflict_cases_path
      end
    end
  end

  def approve_update
    @conflict_case = ConflictCase.find(params[:id])
    if(@conflict_case and @conflict_case.is_updated and @conflict_case.backup and @conflict_case.backup.user.id != current_user.id)
      if @conflict_case.update_to_resource_map
        if(@conflict_case.update_attributes(:location_id => @conflict_case.backup.data["location_id"]))
          flash[:notice] = "You have successfully updated conflict case #{@conflict_case.location.name}."
          @conflict_case.backup.destroy!
          @conflict_case.is_updated = false
          @conflict_case.save
          redirect_to conflict_cases_path
        else
          flash[:error] = "Failed to update conflict location. Please try again later."
          redirect_to conflict_cases_path
        end
      else 
        @conflict_types = ConflictType.all
        @conflict_states = ConflictState.all
        @conflict_intensities = ConflictIntensity.all
        flash[:error] = "Failed to update case on resource map application. Please try again later."
        redirect_to conflict_cases_path
      end
    else
      flash[:error] = "Process update conflict failed."
      redirect_to conflict_cases_path
    end
  end

  def view_difference
    @locations = Location.all
    @fields = ConflictCase.get_fields
    conflict = ConflictCase.find(params[:id])
    @base = ConflictCase.convertToConflictCase(conflict.get_conflict_from_resource_map, @fields)
  end

  def get_field_options
    @fields = ConflictCase.get_fields
    success = false
    @fields.each do |field|
      if params[:field] == field["code"]
        success = true
        render :json => field["options"].to_json 
      end
    end
    unless success
      render :json => {:error => "field not found"}
    end
  end

  def failed_messages
    messages = Message.where('is_success = false').find(:all, :order => "messages.created_at DESC")
    @messages = messages.paginate(:page => params[:page], :per_page => PageSize)
  end
end