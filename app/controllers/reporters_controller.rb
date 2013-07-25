class ReportersController < ApplicationController  
  before_filter :authenticate_user!

  def index  
    if params[:query]
      @query = params[:query]
      @reporters = Reporter.where('last_name like ? OR first_name like ? OR phone_number like ?',"%#{@query}%","%#{@query}%","%#{@query}%").paginate(:page => params[:page], :per_page => 3)
    else
      @reporters = Reporter.all.paginate(:page => params[:page], :per_page => 3)
    end
  end

  def show
  	
  end

  def new
  	@reporter = Reporter.new()
  end

  def create
    @reporter = Reporter.new(params[:reporter])
    if @reporter.create_to_resource_map
    	if @reporter.save
        flash[:notice] = "You have successfully create reporter #{@reporter.first_name} #{@reporter.last_name}."
        redirect_to reporters_path
      else
        render :new
      end
    else
      flash[:error] = "Failed to create reporter on resource map application. Please try again later."
      render :new
    end
  end

  def edit
    @reporter = Reporter.find(params[:id])
  end

  def update
    @reporter = Reporter.find(params[:id])
    if @reporter.update_to_resourcemap params[:reporter]
      if(@reporter.update_attributes(params[:reporter]))
        flash[:notice] = "You have successfully update reporter #{@reporter.first_name} #{@reporter.last_name}."
        redirect_to reporters_path
      else
        render :edit
      end
    else
      flash[:error] = "Failed to update reporter on resource map application. Please try again later."
      render :edit
    end
  end

  def destroy
    @reporter= Reporter.find(params[:id])
    if @reporter.destroy
      flash[:notice] = "You have successfully delete reporter #{@reporter.first_name} #{@reporter.last_name}."
      redirect_to reporters_path
    else
      flash[:error] = "Failed to delete reporter #{@reporter.first_name} #{@reporter.last_name}. Please try again later."
      redirect_to reporters_path
    end
  end
end