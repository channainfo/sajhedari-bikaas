class Reporter < ActiveRecord::Base 
  validates_uniqueness_of :phone_number, :allow_blank => true
  validates_presence_of :first_name
  validates_presence_of :last_name

  attr_accessible :first_name
  attr_accessible :last_name
  attr_accessible :cast
  attr_accessible :sex
  attr_accessible :ethnicity
  attr_accessible :address
  attr_accessible :phone_number

  has_many :conflict_cases

  def create_to_resource_map
    yml = self.load_resource_map
    request = Typhoeus::Request.new(
      yml["url"] + 'api/collections/' + yml["collection_id"].to_s + '/register_new_member',
      method: :post,
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

  def load_resource_map
    YAML.load_file File.expand_path(Rails.root + "config/resourcemap.yml", __FILE__)
  end

end