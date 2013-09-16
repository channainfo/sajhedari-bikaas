class ReportersController < ApplicationController  
  before_filter :authenticate_user!

  def index  
    if params[:query]
      @query = params[:query]
      @reporters = Reporter.where('last_name like ? OR first_name like ? OR phone_number like ?',"%#{@query}%","%#{@query}%","%#{@query}%").paginate(:page => params[:page], :per_page => 3)
    else
      @reporters = Reporter.all.paginate(:page => params[:reporter_page], :per_page => PageSize)
    end
  end

  def show
  	
  end

  def new
  	@reporter = Reporter.new()
  end

  def create
    @reporter = Reporter.new(params[:reporter])
    @reporter.date_of_birth = DateTime.strptime(params["reporter"]["date_of_birth"], "%m-%d-%Y") unless params["reporter"]["date_of_birth"].strip.empty?
    if @reporter.create_to_resource_map
    	if @reporter.save
        flash[:notice] = "You have successfully created reporter #{@reporter.first_name} #{@reporter.last_name}."
        redirect_to reporters_path
      else
        render :new
      end
    else
      flash[:error] = "Failed to create reporter on resource map application. Please try again later."
      render :new
    end
  end

  def test

  end

  def edit
    @reporter = Reporter.find(params[:id])
    @reporter.date_of_birth = @reporter.date_of_birth.strftime("%m-%d-%Y") if @reporter.date_of_birth
  end

  def getReporterCasesPagination
    @fields = ConflictCase.get_fields
    json_data = {}
    table_rows = ""
    site_ids = []

    cases = ConflictCase.all.where(:reporter_id => params[:id]).offset(params[:offset].to_i).limit(5)
    unless cases.empty?
      cases.each do |c|
        site_ids.push(c.site_id)
      end
      sites = ConflictCase.get_some_sites_from_resourcemap(site_ids)
      @reporter_cases = ConflictCase.transform(sites, @fields)
    else
      @reporter_cases = []
    end

    @reporter_cases.count == 0 ? table_rows = "<tr><td colspan='5' style='text-align: center; color: red; padding-top: 20px;'>No records found</td></tr>" : table_row = ""
    @reporter_cases.each do |el|
      location = Location.find_by_id(el.location_id)
      conflict_type = ApplicationController.helpers.field_desc @fields, el.conflict_type, "con_type"
      conflict_intensity = ApplicationController.helpers.field_desc @fields, el.conflict_intensity, "con_intensity"
      conflict_state = ApplicationController.helpers.field_desc @fields, el.conflict_state, "con_state"
      row = "<tr><td style='width: 200px;'>#{el.updated_at.strftime("%m-%d-%Y %H:%M:%S UTC")}</td><td>#{conflict_type}</td><td>#{conflict_intensity}</td><td>#{conflict_state}</td><td>#{location.name}</td></tr>"  
      table_rows = table_rows + row
    end
    json_data["table_row"] = table_rows
    if @reporter_cases.count >= 5
      if (params[:offset].to_i <= 0)
        params[:offset] = 0
        paging = "<div class='pagination' id='paginate_report'><ul>"
        paging += "<li class='active'><a>Prev</a></li>"
        paging += "<li><a style='cursor: pointer;' onclick='updateModalPaging(#{params[:id]},#{params[:offset]} + 5)'>Next</a></li>"
        paging += "</ul> </div>"
      elsif (ConflictCase.count - 5) < params[:offset].to_i 
        paging = "<div class='pagination' id='paginate_report'><ul>"
        paging += "<li><a style='cursor: pointer;' onclick='updateModalPaging(#{params[:id]},#{params[:offset]} - 5)'>Prev</a></li>"
        paging += "<li class='active'><a>Next</a></li>"
        paging += "</ul> </div>"
      else 
        paging = "<div class='pagination' id='paginate_report'><ul>"
        paging += "<li><a style='cursor: pointer;' onclick='updateModalPaging(#{params[:id]},#{params[:offset]} - 5)'>Prev</a></li>"
        paging += "<li><a style='cursor: pointer;' onclick='updateModalPaging(#{params[:id]},#{params[:offset]} + 5)'>Next</a></li>"
        paging += "</ul> </div>"
      end
    else
      if (ConflictCase.count - 5) < params[:offset].to_i && params[:offset].to_i > 0
        paging = "<div class='pagination' id='paginate_report'><ul>"
        paging += "<li><a style='cursor: pointer;' onclick='updateModalPaging(#{params[:id]},#{params[:offset]} - 5)'>Prev</a></li>"
        paging += "<li class='active'><a>Next</a></li>"
        paging += "</ul> </div>"
      end
    end
    json_data["paging"] = paging
    render :json => json_data
  end

  def update
    @reporter = Reporter.find(params[:id])
    if @reporter.update_to_resourcemap params[:reporter]
      if(@reporter.update_attributes(params[:reporter]))
        @reporter.date_of_birth = DateTime.strptime(params["reporter"]["date_of_birth"], "%m-%d-%Y")  unless params["reporter"]["date_of_birth"].strip.empty?
        @reporter.save
        flash[:notice] = "You have successfully updated reporter #{@reporter.first_name} #{@reporter.last_name}."
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
    if @reporter.never_sent_case
      if @reporter.destroy_from_resource_map
        if @reporter.destroy
          flash[:notice] = "You have successfully deleted reporter #{@reporter.first_name} #{@reporter.last_name}."
          redirect_to reporters_path
        else
          flash[:error] = "Failed to delete reporter #{@reporter.first_name} #{@reporter.last_name}. Please try again later."
          redirect_to reporters_path
        end
      else
        flash[:error] = "Failed to delete reporter #{@reporter.first_name} #{@reporter.last_name} from Resource map application."
        redirect_to reporters_path
      end
    else
      flash[:error] = "Failed to delete reporter #{@reporter.first_name} #{@reporter.last_name}. This reporter has sent some cases to the system."
      redirect_to reporters_path
    end
  end
end