require 'open-uri'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role_id , :ethnicity, :cast, :sex, :first_name, :last_name, :address, :phone_number
  belongs_to :role  
  validates_uniqueness_of :phone_number, :allow_blank => true


  USER_NAME, PASSWORD = 'iLab', '1c4989610bce6c4879c01bb65a45ad43'

  def is_admin?
  	self.role == Role.find_by_name("Admin")
  end

  def is_super_admin?
  	self.role == Role.find_by_name("Super Admin")
  end

  def create_to_resourcemap
    request = Typhoeus::Request.new(
      "http://localhost:3000/sb/create_user",
      method: :post,
      params: { "user[email]" => self.email, 
                "user[password]" => self.password, 
                "user[password_confirmation]" => self.password, 
                "user[phone_number]" => self.phone_number,
                "user[confirmed_at]" => Time.now(),
                "role" => self.role.name,
                "collection_id" => 10
              },
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.return_code
    return response == :ok
  end

  def update_to_resourcemap user
    request = Typhoeus::Request.new(
      "http://localhost:3000/sb/update_user",
      method: :put,
      params: { "user[email]" => user["email"], 
                "user[phone_number]" => user["phone_number"],
                "role" => Role.find(user["role_id"].to_i).name,
                "collection_id" => 10
              },
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.return_code
    return response == :ok
  end
end