class Role < ActiveRecord::Base
  has_one :role  
  validates_uniqueness_of :name, :allow_blank => true

end