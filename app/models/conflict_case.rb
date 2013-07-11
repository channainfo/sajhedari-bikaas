class ConflictCase < ActiveRecord::Base
  belongs_to :conflict_type
  belongs_to :conflict_intensity
  belongs_to :conflict_state
  belongs_to :location
end
