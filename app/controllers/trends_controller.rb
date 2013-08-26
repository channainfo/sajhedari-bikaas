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
      graph_data = ConflictCase.generate_graph_data conflict_cases, params[:data]
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