class Location < ActiveRecord::Base    
  validates_uniqueness_of :code, :allow_blank => true
  validates_presence_of :name
  validates_presence_of :lat
  validates_presence_of :lng
  validates_presence_of :code
  attr_accessible :name
  attr_accessible :lat
  attr_accessible :lng
  attr_accessible :code

  def update_to_resourcemap
  	 request = Typhoeus::Request.new(
       "http://localhost:3000/api/collections/1/sites/1.json",
       method: :put,
       body: "this is a request body",
       params: { name: self.name, lat: self.lat, lng: self.lng },
       headers: { Accept: "text/html" }
     )
     request.run
     response = request.response
     if(response.return_code == :ok)
       p response.response_body
     end
	end

end