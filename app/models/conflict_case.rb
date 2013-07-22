class ConflictCase < ActiveRecord::Base
  belongs_to :conflict_type
  belongs_to :conflict_intensity
  belongs_to :conflict_state
  belongs_to :location
  belongs_to :reporter

  attr_accessible :conflict_type_id
  attr_accessible :conflict_intensity_id
  attr_accessible :conflict_state_id
  attr_accessible :location_id
  attr_accessible :case_message
  attr_accessible :site_id
  attr_accessible :reporter_id

  def save_case_to_resource_map
    yml = self.load_resource_map
    request = Typhoeus::Request.new(
       yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites",
       method: :post,
       body: "this is a request body",
       params: { lat: self.location.lat, 
                 lng: self.location.lng, 
                 # name: self.user.username,
                 name: self.case_message, 
                 email: self.reporter.email,
                 conflict_type: self.conflict_type.name,
                 conflict_intensity: self.conflict_intensity.name,
                 conflict_state: self.conflict_state.name },
       headers: { Accept: "text/html" }
     )
     request.run
     response = request.response
     if(response.return_code == :ok)
       result = JSON.parse response.response_body
       return result["site"]
     end
  end

  def update_to_resource_map params
    yml = self.load_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
       yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites/" + site_id,
       method: :put,
       body: "this is a request body",
       params: { email: self.user.email,
                 lat: Location.find_by_id(params[:location_id].to_i).lat, 
                 lng: Location.find_by_id(params[:location_id].to_i).lng, 
                 conflict_type: ConflictType.find_by_id(params[:conflict_type_id].to_i).name,
                 conflict_intensity: ConflictIntensity.find_by_id(params[:conflict_intensity_id].to_i).name,
                 conflict_state: ConflictState.find_by_id(params[:conflict_state_id].to_i).name },
       headers: { Accept: "text/html" }
     )
    request.run
    response = request.response.code
    return response == 200
  end

  def destroy_case_from_resource_map
    yml = self.load_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
       yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites/" + site_id,
       method: :delete,
       body: "this is a request body",
       params: {},
       headers: { Accept: "text/html" }
     )
     request.run
  end

  def load_resource_map
    YAML.load_file File.expand_path(Rails.root + "config/resourcemap.yml", __FILE__)
  end
end
