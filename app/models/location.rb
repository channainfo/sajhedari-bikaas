class Location < ActiveRecord::Base    
  validates_uniqueness_of :code, :allow_blank => true
  validates_presence_of :name
  validates_presence_of :lat
  validates_presence_of :lng
  validates_presence_of :code
  validates_numericality_of :lat, :greater_than_or_equal_to => -90, :less_than_or_equal_to => 90 ,:message => "must be less than 90 and larger than -90"
  validates_numericality_of :lng, :greater_than_or_equal_to => -180, :less_than_or_equal_to => 180, :message => "must be less than 180 and larger than -180"

  
  attr_accessible :name
  attr_accessible :lat
  attr_accessible :lng
  attr_accessible :code
  attr_accessible :is_deleted
  attr_accessible :is_updated
  USER_NAME, PASSWORD = 'iLab', '1c4989610bce6c4879c01bb65a45ad43'

  def lnglat
    "#{lng},#{lat}"
  end

  def description
    name + "(" + code + ")"
  end

  def update_to_resourcemap site_ids, user_emails
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/update_sites",
      userpwd: "#{USER_NAME}:#{PASSWORD}",
      method: :put,
      body: "this is a request body",
      params: { lat: self.backup.data["lat"], lng: self.backup.data["lng"], site_id: site_ids, user_email: user_emails },
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
	end

  def self.update_latlng_to_resourcemap site_ids, user_emails, new_lat, new_lng
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/update_sites",
      userpwd: "#{USER_NAME}:#{PASSWORD}",
      method: :put,
      body: "this is a request body",
      params: { lat: new_lat, lng: new_lng, site_id: site_ids, user_email: user_emails },
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
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

  def self.get_category
    'location'
  end

  def backup
    backup = Backup.find_by_entity_id_and_category(self.id, Location.get_category)
    backup.data = JSON.parse backup.data if backup
    backup
  end

  def never_present_in_conflict
    ConflictCase.find_by_location_id(self.id) == nil
  end

end