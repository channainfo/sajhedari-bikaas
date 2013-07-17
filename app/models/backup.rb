class Backup < ActiveRecord::Base    
  attr_accessible :category
  attr_accessible :data
  attr_accessible :entity_id
  attr_accessible :user_id

  belongs_to :user

end