class ConflictCase < ActiveRecord::Base
  belongs_to :location
  belongs_to :reporter

  attr_accessible :location_id
  attr_accessible :case_message
  attr_accessible :site_id
  attr_accessible :conflict_intensity
  attr_accessible :conflict_state
  attr_accessible :conflict_type

  attr_accessible :reporter, :location, :conflict_type_description, :conflict_intensity_description, :conflict_state_description

  attr_accessible :is_deleted
  attr_accessible :is_updated
  attr_accessible :reporter_id

  attr_accessor :conflict_type_description, :conflict_intensity_description, :conflict_state_description

  def field_description fields, property
    property_code = self.translate(property)

    fields.each do |f|
        if(f["code"] == property)
          options = f["options"]
          options.each do |option|
            return option["label"] if(option["code"] == property_code)
          end
        end
    end
    raise "Unknow property: " + property + " with code: " + property_code
  end

  def con_type_description fields
    field_description fields, 'con_type'
  end

  def con_intensity_description fields
    field_description fields, 'con_intensity'
  end

  def con_state_description fields
    field_description fields, 'con_state'
  end

  def translate property
    if property == "con_type"
      self.conflict_type.to_s
    elsif property == "con_intensity"
      self.conflict_intensity.to_s
    else property == "con_state"
      self.conflict_state.to_s     
    end
  end

  def save_case_to_resource_map option
    params = { lat: self.location.lat, 
                 lng: self.location.lng, 
                 name: self.location.name, 
                 phone_number: self.reporter.phone_number,
                 conflict_type: option[:conflict_type],
                 conflict_intensity: option[:conflict_intensity],
                 conflict_state: option[:conflict_state] ,
                 headers: { Accept: "text/html" }
            }
    request = Typhoeus::Request.new(
       ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites",
       method: :post,
       body: "this is a request body",
       params: params
     )
     request.run
     response = request.response
     if(response.code == 200)
       result = JSON.parse response.response_body
       return result["site"]
     end
  end

  def update_to_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
       ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites/" + site_id,
       method: :put,
       body: "this is a request body",
       params: { phone_number: self.reporter.phone_number,
                 lat: Location.find_by_id(self.backup.data["location_id"].to_i).lat, 
                 lng: Location.find_by_id(self.backup.data["location_id"].to_i).lng,
                 name: Location.find_by_id(self.backup.data["location_id"].to_i).name, 
                 conflict_type: self.backup.data["conflict_type"].to_i,
                 conflict_intensity: self.backup.data["conflict_intensity"].to_i,
                 conflict_state: self.backup.data["conflict_state"].to_i 
                },
       headers: { Accept: "text/html" }
     )
    request.run
    response = request.response.code
    return response == 200
  end

  def update_to_resource_map_with_form params
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
       ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites/" + site_id,
       method: :put,
       body: "this is a request body",
       params: { phone_number: self.reporter.phone_number,
                 lat: Location.find_by_id(self.backup.data["location_id"].to_i).lat, 
                 lng: Location.find_by_id(self.backup.data["location_id"].to_i).lng, 
                 name: Location.find_by_id(self.backup.data["location_id"].to_i).name, 
                 conflict_type: params["conflict_type"].to_i,
                 conflict_intensity: params["conflict_intensity"].to_i,
                 conflict_state: params["conflict_state"].to_i 
                },
       headers: { Accept: "text/html" }
     )
    request.run
    response = request.response.code
    return response == 200
  end

  def destroy_case_from_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
    ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites/" + site_id,
      method: :delete,
      body: "this is a request body",
      params: {},
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
  end

  def self.get_all_sites_from_resource_map()
    request = Typhoeus::Request.new(
    ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites",
      method: :get,
      body: "this is a request body",
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)
  end

  def self.get_paging_sites_from_resource_map(limit, offset)
    request = Typhoeus::Request.new(
    ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites",
      method: :get,
      body: "this is a request body",
      params: {:limit => limit, :offset => offset},
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)
  end


  def self.all_from_resource_map
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites",
      method: :get
    )
    request.run
    JSON.parse(request.response.body)
  end

  def self.get_all_sites_from_resource_map_by_period(start_date, end_date)
    request = Typhoeus::Request.new(
          ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites",
          method: :get,
          body: "this is a request body",
          headers: { Accept: "text/html" },
          params: {:start_date => start_date, :end_date => end_date } 
    )

    request.run
    response = request.response.response_body
    return JSON.parse(response)
  end

  def get_conflict_from_resource_map
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites/" + self.site_id.to_s,
      method: :get,
      body: "this is a request body",
      params: {},
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)
  end


  def self.get_category
    'conflict_case'
  end

  def backup
    backup = Backup.find_by_entity_id_and_category(self.id, ConflictCase.get_category)
    backup.data = JSON.parse backup.data if backup
    backup
  end

  def self.get_fields
    request = Typhoeus::Request.new(
    ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/get_fields.json",
      method: :get,
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response
    if response.code == 200
      fields = JSON.parse response.response_body
      return fields
    else
      return nil
    end
  end

  def self.transform sites, fields
    conflict_cases = []
    sites.each do |site|
      conflict_cases.push(convertToConflictCase(site, fields))
    end
    conflict_cases
  end

  def self.convertToConflictCase site, fields
    conflict = ConflictCase.find_by_site_id(site["id"])
    properties = site["properties"]
    properties.each do |key, value|
      conflict = assign_value conflict, key, value, fields
    end
    conflict
  end

  def self.assign_value conflict, key, value, fields
    fields.each do |f|
      if f["id"] == key.to_i
        case f["code"]
          when "con_state"
            conflict.conflict_state = value
            conflict.conflict_state_description = conflict.con_state_description fields
          when "con_type"
            conflict.conflict_type = value
            conflict.conflict_type_description = conflict.con_type_description fields
          when "con_intensity"
            conflict.conflict_intensity = value
            conflict.conflict_intensity_description = conflict.con_intensity_description fields
        end
      end
    end
    conflict
  end

  def meet_alert?(condition)
    return false unless condition.size > 0
    condition.each do |key, value|
      case key
        when "con_state"
          return false unless self.conflict_state == value.to_i
        when "con_type"
          return false unless self.conflict_type == value.to_i
        when "con_intensity"
          return false unless self.conflict_intensity == value.to_i
      end
    end
    return true
  end
end
