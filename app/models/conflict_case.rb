class ConflictCase < ActiveRecord::Base
  belongs_to :conflict_type
  belongs_to :conflict_intensity
  belongs_to :conflict_state
  belongs_to :location

  attr_accessible :conflict_type_id
  attr_accessible :conflict_intensity_id
  attr_accessible :conflict_state_id
  attr_accessible :location_id
  attr_accessible :case_message
  attr_accessible :site_id
  attr_accessible :user_id
end
