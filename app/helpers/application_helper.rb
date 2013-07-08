module ApplicationHelper
	def section_active(action)
    	return (params[:controller] == action)? "active": ""
    end

    def is_super_admin? user
    	user.role.name == "Super Admin"
    end

    def is_admin? user
    	user.role.name == "Admin"
    end
end
