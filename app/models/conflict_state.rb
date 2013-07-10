class ConflictState < ActiveRecord::Base

	has_many :cases

	BEFORE_THE_CONFLICT = 1
	AFTER_THE_CONFLICT = 2
end
