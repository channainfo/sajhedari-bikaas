class ReportersController < ApplicationController  
  before_filter :authenticate_user!

  def index
    @reporters = Reporter.all.paginate(:page => params[:page], :per_page => 10)
  end

  def show
  	
  end

  def new
  	@reporter = Reporter.new()
  end

  def create
    reporter = Reporter.new(params[:reporter])
  	if reporter.save
      redirect_to reporters_path
    else
      redirect_to new_reporter_path
    end
  end

  def edit
    @reporter = Reporter.find(params[:id])
  end

  def update
    reporter = Reporter.find(params[:id])
    if(reporter.update_attributes(params[:reporter]))
      redirect_to reporters_path
    else
      redirect_to edit_reporter_path(reporter)
    end
  end

  def destroy
    Reporter.find(params[:id]).destroy
    redirect_to reporters_path
  end
end