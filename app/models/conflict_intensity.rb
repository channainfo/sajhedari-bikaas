class ConflictIntensity < ActiveRecord::Base

	has_many :cases


	LOW = 1
	MODERATE = 2
	HIGH = 3

end
