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


end