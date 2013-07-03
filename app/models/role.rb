class Role < ActiveRecord::Base
  has_one :user  
  validates_uniqueness_of :name, :allow_blank => true

end