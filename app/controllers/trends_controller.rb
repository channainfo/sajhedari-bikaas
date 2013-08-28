class TrendsController < ApplicationController  
	
	def index  
		
	end

	def fetchCaseForGraph
    fields = ConflictCase.get_fields
    result = []
    arr_color = []
    colors = ['#FF3333','#3333FF', '#800080', '#556B2F', '#8B4513']
    if fields
      con_type = params[:data].split(",")
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
      graph_data.unshift(header)
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
end