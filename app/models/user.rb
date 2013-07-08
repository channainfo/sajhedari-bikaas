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

  def filter_user_role
  	# self.role = Role.find_by_name("Admin") if(current_user.role == Role.find_by_name("Admin"))
  end


  def is_admin?
  	self.role == Role.find_by_name("Admin")
  end

  def is_super_admin?
  	self.role == Role.find_by_name("Super Admin")
  end
end