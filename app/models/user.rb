require 'open-uri'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role_id , :cast_ethnicity, :date_of_birth, :sex, :first_name, :last_name, :address, :phone_number
  belongs_to :role  
  validates_uniqueness_of :phone_number, :allow_blank => true
  validates_uniqueness_of :email, :allow_blank => true


  USER_NAME, PASSWORD = 'iLab', '1c4989610bce6c4879c01bb65a45ad43'

  def is_admin?
  	self.role == Role.find_by_name("Admin")
  end

  def is_super_admin?
  	self.role == Role.find_by_name("Super Admin")
  end

  def create_to_resourcemap
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + 'api/collections/' + ResourceMapConfig["collection_id"].to_s + '/memberships',
      method: :post,
      params: { "user[email]" => self.email, 
                "user[password]" => self.password, 
                "user[password_confirmation]" => self.password_confirmation, 
                "user[phone_number]" => self.phone_number,
                "user[confirmed_at]" => Time.now(),
                "role" => self.role.name
              },
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
  end

  def update_to_resourcemap user
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + 'api/collections/' + ResourceMapConfig["collection_id"].to_s + '/memberships',
      method: :put,
      params: { "user[email]" => user["email"], 
                "user[phone_number]" => user["phone_number"],
                "role" => Role.find(user["role_id"].to_i).name
              },
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
  end

  def destroy_from_resourcemap 
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + 'api/collections/' + ResourceMapConfig["collection_id"].to_s + '/destroy_member',
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

  def update_password_to_resourcemap user
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + 'api/collections/' + ResourceMapConfig["collection_id"].to_s + '/memberships',
      method: :put,
      params: { 
                "user[password]" => user["password"],
                "user[password_confirmation]" => user["password_confirmation"],
                "user[email]" => self.email
              },
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
  end

end