class ConflictCasesController < ApplicationController  
  before_filter :authenticate_user!

  def index
    @conflict_cases = ConflictCase.all.paginate(:page => params[:page], :per_page => 3)
  end

  def show
  	
  end

  def new
    @locations = Location.all
    @conflict_types = ConflictType.all
    @conflict_states = ConflictState.all
    @conflict_intensities = ConflictIntensity.all
    @reporters = Reporter.all
  	@conflict_case = ConflictCase.new()
  end

  def create
    @conflict_case = ConflictCase.new(params[:conflict_case])
    site = @conflict_case.save_case_to_resource_map
    if site
      @conflict_case.site_id = site["id"]
    	if @conflict_case.save
        flash[:notice] = "You have successfully create conflict case #{@conflict_case.case_message}."      
        redirect_to conflict_cases_path
      else
        render :new
      end
    else
      flash[:error] = "Failed to case on resource map application. Please try again later."
      render :new
    end
  end

  def edit
    @locations = Location.all
    @conflict_types = ConflictType.all
    @conflict_states = ConflictState.all
    @conflict_intensities = ConflictIntensity.all
    @conflict_case = ConflictCase.find(params[:id])
  end

  # def update
  #   @conflict_case = ConflictCase.find(params[:id])
  #   if @conflict_case.update_to_resource_map params[:conflict_case]
  #     if(@conflict_case.update_attributes(params[:conflict_case]))
  #       flash[:notice] = "You have successfully update conflict case #{@conflict_case.case_message}."
  #       redirect_to conflict_cases_path
  #     else
  #       render :edit
  #     end
  #   else 
  #     @conflict_types = ConflictType.all
  #     @conflict_states = ConflictState.all
  #     @conflict_intensities = ConflictIntensity.all
  #     flash[:error] = "Failed to update case on resource map application. Please try again later."
  #     render :edit
  #   end
  # end

  def update
    @conflict_case = ConflictCase.find(params[:id])
    if @conflict_case.is_updated       
      unless @conflict_case.backup.user.id == current_user.id
        flash[:error] = "Case #{@conflict_case.case_message} is marked as update please click Approve to update to confirm update location."
        redirect_to conflict_cases_path
      else
        flash[:error] = "Failed to update case #{@conflict_case.case_message}. Please try again later."
        redirect_to conflict_cases_path
      end

    else
      flash[:notice] = "#{@conflict_case.location.name} is mark as updated."
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
        flash[:error] = "Conflict Case is marked as delete please click Approve to delete to confirm delete location."
        redirect_to conflict_cases_path
      else
        flash[:error] = "Failed to delete Conflict Case. Please try again later."
        redirect_to conflict_cases_path
      end
    else
      flash[:notice] = "Conflict Case is mark as deleted."
      Backup.create!(:entity_id => @conflict_case.id, :data => @conflict_case.to_json, :category => ConflictCase.get_category, :user_id => current_user.id)
      @conflict_case.is_deleted = true
      @conflict_case.save
      redirect_to conflict_cases_path
    end
  end

  def cancel_delete
    @conflict_case = ConflictCase.find(params[:id])
    if(@conflict_case.is_deleted and @conflict_case.backup)
      flash[:notice] = "#{@conflict_case.case_message} is mark as undeleted."
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
      flash[:notice] = "#{@conflict_case.case_message} is mark as not update."
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
      flash[:notice] = "You have successfully delete #{@conflict_case.case_message}."
      redirect_to conflict_cases_path
    else
      flash[:error] = "Process delete #{@conflict_case.case_message} failed."
      redirect_to conflict_cases_path
    end
  end

  def apply_update_form
    @conflict_case = ConflictCase.find(params[:id])
    if(@conflict_case and @conflict_case.is_updated and @conflict_case.backup and @conflict_case.backup.user.id != current_user.id)
      if @conflict_case.update_to_resource_map params[:conflict_case]
        if(@conflict_case.update_attributes(@conflict_case.backup.data))
          flash[:notice] = "You have successfully update conflict case #{@conflict_case.case_message}."
          @conflict_case.backup.destroy!
          @conflict_case.is_updated = false
          @conflict_case.save
          redirect_to conflict_cases_path
        else
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
      if @conflict_case.update_to_resource_map params[:conflict_case]
        if(@conflict_case.update_attributes(@conflict_case.backup.data))
          flash[:notice] = "You have successfully update conflict case #{@conflict_case.case_message}."
          @conflict_case.backup.destroy!
          @conflict_case.is_updated = false
          @conflict_case.save
          redirect_to conflict_cases_path
        else
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

  def view_difference
    @locations = Location.all
    @conflict_types = ConflictType.all
    @conflict_states = ConflictState.all
    @conflict_intensities = ConflictIntensity.all
    @base = ConflictCase.find(params[:id])
  end
end