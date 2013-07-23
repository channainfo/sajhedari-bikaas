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

end