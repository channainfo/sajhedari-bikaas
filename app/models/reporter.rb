class Reporter < ActiveRecord::Base 
  validates_uniqueness_of :phone_number, :allow_blank => true
  validates_presence_of :first_name
  validates_presence_of :last_name

  attr_accessible :first_name
  attr_accessible :last_name
  attr_accessible :cast_ethnicity
  attr_accessible :sex
  attr_accessible :date_of_birth
  attr_accessible :address
  attr_accessible :phone_number

  has_many :conflict_cases
  USER_NAME, PASSWORD = 'iLab', '1c4989610bce6c4879c01bb65a45ad43'

  def full_name
    "#{first_name} #{last_name}"
  end

  def create_to_resource_map
    yml = self.load_resource_map
    request = Typhoeus::Request.new(
      yml["url"] + 'api/collections/' + yml["collection_id"].to_s + '/register_new_member',
      method: :post,
      userpwd: "#{USER_NAME}:#{PASSWORD}",
      params: { "user[email]" => "", 
                "user[password]" => "", 
                "user[phone_number]" => self.phone_number
              },
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
  end

  def update_to_resourcemap reporter
    yml = self.load_resource_map
    request = Typhoeus::Request.new(
      yml["url"] + 'api/collections/' + yml["collection_id"].to_s + '/memberships',
      method: :put,
      userpwd: "#{USER_NAME}:#{PASSWORD}",
      params: { "user[phone_number]" => reporter["phone_number"],
                "role" => "reporter",
                "reporter_phone" => self.phone_number
              },
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
  end

  def load_resource_map
    YAML.load_file File.expand_path(Rails.root + "config/resourcemap.yml", __FILE__)
  end

  def never_sent_case
    ConflictCase.find_by_reporter_id(self.id) == nil
  end

  def destroy_from_resource_map
    yml = self.load_resource_map
    request = Typhoeus::Request.new(
      yml["url"] + 'api/collections/' + yml["collection_id"].to_s + '/destroy_member',
      method: :delete,
      userpwd: "#{USER_NAME}:#{PASSWORD}",
      params: { 
                "user[phone_number]" => self.phone_number
              },
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
  end

end