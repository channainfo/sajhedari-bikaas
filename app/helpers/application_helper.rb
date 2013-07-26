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

    def field_desc(fields, conflict_type_id, field_code)
    	fields.each do |f|
    		if(f["code"] == field_code)
    			options = f["options"]
    			options.each do |option|
    				if option["code"] == conflict_type_id.to_s
    					return option["label"]
    				end
    			end
    		end
    	end
    	return conflict_type_id
    end

    def field_by_code(fields, field_code)
        fields.each do |f|
            if(f["code"] == field_code)
                return f["options"]
            end
        end
        return []
    end
end
