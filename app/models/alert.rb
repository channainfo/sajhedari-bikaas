class Alert < ActiveRecord::Base    
  validates_presence_of :name
  validates_presence_of :last_days
  validates_presence_of :total
  validates_presence_of :condition
  attr_accessible :name
  attr_accessible :last_days
  attr_accessible :total
  attr_accessible :condition


end