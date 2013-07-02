class Location < ActiveRecord::Base    
  validates_uniqueness_of :name, :allow_blank => true

end