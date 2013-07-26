class ConflictCase < ActiveRecord::Base
  belongs_to :location
  belongs_to :reporter

  attr_accessible :location_id
  attr_accessible :case_message
  attr_accessible :site_id
  attr_accessible :conflict_intensity
  attr_accessible :conflict_state
  attr_accessible :conflict_type

  attr_accessible :is_deleted
  attr_accessible :is_updated
  attr_accessible :reporter_id

  def save_case_to_resource_map
    yml = self.class.load_resource_map
    request = Typhoeus::Request.new(
       yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites",
       method: :post,
       body: "this is a request body",
       params: { lat: self.location.lat, 
                 lng: self.location.lng, 
                 name: self.location.name, 
                 phone_number: self.reporter.phone_number,
                 conflict_type: self.conflict_type,
                 conflict_intensity: self.conflict_intensity,
                 conflict_state: self.conflict_state },
       headers: { Accept: "text/html" }
     )
     request.run
     response = request.response
     if(response.code == 200)
       result = JSON.parse response.response_body
       return result["site"]
     end
  end

  def update_to_resource_map params
    yml = self.class.load_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
       yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites/" + site_id,
       method: :put,
       body: "this is a request body",
       params: { phone_number: self.reporter.phone_number,
                 lat: Location.find_by_id(self.backup.data["location_id"].to_i).lat, 
                 lng: Location.find_by_id(self.backup.data["location_id"].to_i).lng, 
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

  def destroy_case_from_resource_map
    yml = self.class.load_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
    yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites/" + site_id,
      method: :delete,
      body: "this is a request body",
      params: {},
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
  end

  def self.get_category
    'conflict_case'
  end

  def backup
    backup = Backup.find_by_entity_id_and_category(self.id, ConflictCase.get_category)
    backup.data = JSON.parse backup.data if backup
    backup
  end

  def self.load_resource_map
    YAML.load_file File.expand_path(Rails.root + "config/resourcemap.yml", __FILE__)
  end

  def self.get_fields
    yml = load_resource_map
    request = Typhoeus::Request.new(
    yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/get_fields.json",
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
end
