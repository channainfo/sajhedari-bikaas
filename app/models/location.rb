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

  def update_to_resourcemap site_ids, user_emails
     yml = self.load_resource_map
  	 request = Typhoeus::Request.new(
       # yml["url"] + "api/collections/1/update_sites",
       'http://localhost:3001/api/collections/1/update_sites',
       method: :put,
       body: "this is a request body",
       params: { lat: self.lat, lng: self.lng, site_id: site_ids, user_email: user_emails },
       headers: { Accept: "text/html" }
     )
     request.run
     response = request.response
     if(response.return_code == :ok)
       p response.response_body
     end
	end

  def self.generate_site_id conflict_cases
    array_site = []
    conflict_cases.each do |el|
      array_site << el.site_id
    end
    site_ids = array_site.join(",")
    return site_ids
  end 

  def self.generate_user_email conflict_cases
    array_email = []
    conflict_cases.each do |el|
      array_email << User.find_by_id(el.user_id).email
    end
    user_emails = array_email.join(",")
    return user_emails
	end

  def load_resource_map
    YAML.load_file File.expand_path(Rails.root + "config/resourcemap.yml", __FILE__)
  end

end