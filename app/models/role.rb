class Role < ActiveRecord::Base
	has_many :user
	validates_uniqueness_of :name, :allow_blank => true
	attr_accessible :name

end