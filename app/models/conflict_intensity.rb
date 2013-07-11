class ConflictIntensity < ActiveRecord::Base

	has_many :conflict_cases


	LOW = 1
	MODERATE = 2
	HIGH = 3

end
