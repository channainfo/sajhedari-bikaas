class TrendsController < ApplicationController  
	
	def index  
		@colors = ['#FF3333', '#000000','#3333FF', '#800080', '#556B2F', '#8B4513','#00FF00', '#899989', '#5E6BFD', '#8BF444']
    fields = ConflictCase.get_fields
    fields.each do |f|
      if f["code"] == Setting.first.conflict_type_code
        @options = f["options"]
      end
    end
	end

  def download_csv
    fields = ConflictCase.get_fields
    if fields
      con_type = params[:data].split(",")
      header = ConflictCase.generate_csv_headers(con_type)
      sites = ConflictCase.get_sites_bases_on_conflict_type_from_resourcemap params 
      if sites.count > 0
        conflict_cases = ConflictCase.transform(sites, fields)
        if params[:frequently] == "Daily"
          graph_data = ConflictCase.generate_daily_graph conflict_cases, params
        elsif params[:frequently] == "Weekly"
          graph_data = ConflictCase.generate_weekly_graph conflict_cases, params
        elsif params[:frequently] == "Montly"
          graph_data = ConflictCase.generate_montly_graph conflict_cases, params
        elsif params[:frequently] == "Quarterly"
          graph_data = ConflictCase.generate_quarterly_graph conflict_cases, params
        elsif params[:frequently] == "Semi annual"
          graph_data = ConflictCase.generate_semi_annual_graph conflict_cases, params
        elsif params[:frequently] == "Yearly"
          graph_data = ConflictCase.generate_yearly_graph conflict_cases, params
        end
        graph_data[0].unshift(header)
        respond_to do |format|
          format.html
          format.csv {render text: ConflictCase.generate_csv_content(graph_data[0])}
        end
      else
        flash[:error] = "Failed to download excel, please choose conflict type."
        redirect_to trends_path
      end
    end
  end

	def fetchCaseForGraph
    fields = ConflictCase.get_fields
    result = []
    arr_color = []
    colors = ['#FF3333', '#000000','#3333FF', '#800080', '#556B2F', '#8B4513','#00FF00', '#899989', '#5E6BFD', '#8BF444']
    if fields
      con_type = params[:data].split(",")
      if ((params[:from].blank? && params[:to].blank?) || ((!params[:from].blank?) && (!params[:to].blank?)))
        # if (params[:from] && params[:to])
        sites = ConflictCase.get_sites_bases_on_conflict_type_from_resourcemap params
        conflict_cases = ConflictCase.transform(sites, fields)
        if params[:frequently] == "Daily"
          graph_data = ConflictCase.generate_daily_graph conflict_cases, params
        elsif params[:frequently] == "Weekly"
          graph_data = ConflictCase.generate_weekly_graph conflict_cases, params
        elsif params[:frequently] == "Montly"
          graph_data = ConflictCase.generate_montly_graph conflict_cases, params
        elsif params[:frequently] == "Quarterly"
          graph_data = ConflictCase.generate_quarterly_graph conflict_cases, params
        elsif params[:frequently] == "Semi annual"
          graph_data = ConflictCase.generate_semi_annual_graph conflict_cases, params
        elsif params[:frequently] == "Yearly"
          graph_data = ConflictCase.generate_yearly_graph conflict_cases, params
        end
        header = ConflictCase.generate_header params[:data]
        graph_data[0].unshift(header)
        result << graph_data
        if con_type.size == 0
          arr_color << "#FF3333"
        end
        con_type.each do |con|
          arr_color << colors[con.to_i - 1]
        end
        result << arr_color
        render :json => result
      end
    end
    if result.count == 0
      redirect_to trends_path
    end
  end
end