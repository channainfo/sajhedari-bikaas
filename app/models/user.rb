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

  before_save :filter_user_role

  USER_NAME, PASSWORD = 'iLab', '1c4989610bce6c4879c01bb65a45ad43'

  def filter_user_role
  	# self.role = Role.find_by_name("Admin") if(current_user.role == Role.find_by_name("Admin"))
  end


  def is_admin?
  	self.role == Role.find_by_name("Admin")
  end

  def is_super_admin?
  	self.role == Role.find_by_name("Super Admin")
  end

  def update_to_resourcemap
    # request = Typhoeus::Request.new(
    #   "http://localhost:3000/sb",
    #   method: :post,
    #   body: "this is a request body",
    #   params: { user: self },
    #   headers: { Accept: "text/html" }
    # )
    # request.run
    # response = request.response
    # if(response.return_code == :ok)
    #   p response.response_body
    # end
  end
end