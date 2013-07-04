module ApplicationHelper
	def section_active(action)
    	return (params[:controller] == action)? "active": ""
    end
end
