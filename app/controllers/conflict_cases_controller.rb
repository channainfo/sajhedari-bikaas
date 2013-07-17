class ConflictCasesController < ApplicationController  
  before_filter :authenticate_user!

  def index
    @conflict_cases = ConflictCase.all.paginate(:page => params[:page], :per_page => 3)
  end

  def show
  	
  end

  def new
  	@conflict_case = ConflictCase.new()
  end

  def create
    @conflict_case = ConflictCase.new(params[:conflict_case])
    site = @conflict_case.save_case_to_resource_map
    @conflict_case.site_id = site["id"]
  	if @conflict_case.save
      flash[:notice] = "You have successfully create conflict case #{@conflict_case.case_message}."      
      redirect_to conflict_cases_path
    else
      render :new
    end
  end

  def edit
    @conflict_case = ConflictCase.find(params[:id])
  end

  def update
    @conflict_case = ConflictCase.find(params[:id])
    if(@conflict_case.update_attributes(params[:conflict_case]))
      flash[:notice] = "You have successfully update conflict case #{@conflict_case.case_message}."
      redirect_to conflict_cases_path
    else
      render :edit
    end
  end

  def destroy
    @conflict_case = ConflictCase.find(params[:id])
    @conflict_case.destroy_case_from_resource_map
    if @conflict_case.destroy
      flash[:notice] = "You have successfully delete conflict case #{@conflict_case.case_message}."
      redirect_to conflict_cases_path
    else
      flash[:error] = "Failed to delete conflict case #{@conflict_case.case_message}. Please try again later."
      redirect_to conflict_cases_path
    end
  end
end