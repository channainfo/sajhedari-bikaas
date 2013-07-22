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
    request = Typhoeus::Request.new(
       # yml["url"] + "api/collections/1/update_sites",
       'http://localhost:3000/api/collections/1/sites',
       method: :post,
       body: "this is a request body",
       params: { lat: self.location.lat, 
                 lng: self.location.lng, 
                 # name: self.user.username,
                 name: "with property", 
                 email: self.reporter.email,
                 conflict_type: self.conflict_type.name,
                 conflict_intensity: self.conflict_intensity.name,
                 conflict_state: self.conflict_intensity.name },
       headers: { Accept: "text/html" }
     )
     request.run
     response = request.response
     if(response.return_code == :ok)
       result = JSON.parse response.response_body
       return result["site"]
     end
  end

  def destroy_case_from_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
       # yml["url"] + "api/collections/1/update_sites",
       'http://localhost:3000/api/collections/1/sites/'+site_id,
       method: :delete,
       body: "this is a request body",
       params: {},
       headers: { Accept: "text/html" }
     )
     request.run
     # response = request.response
     # if(response.return_code == :ok)
     #   result = JSON.parse response.response_body
     #   return result["site"]
     # end
  end
end
