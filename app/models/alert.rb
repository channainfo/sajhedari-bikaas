class Alert < ActiveRecord::Base    
  validates_presence_of :name
  validates_presence_of :last_days
  validates_presence_of :total
  validates_presence_of :condition
  attr_accessible :name
  attr_accessible :last_days
  attr_accessible :total
  attr_accessible :condition

  def full_description
  	fields = ConflictCase.get_fields
  	condition_list = []
  	JSON.parse(self.condition).each do |key,value|
  		fields.each do |f|
  			if f["code"] == key
  				condition_list.push(f["name"].to_s + " is equal to " + value)
  			end
  		end
  	end
  	condition_list.join(" and ")
  end


end