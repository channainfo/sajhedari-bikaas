# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.find_or_create_by_name :name => "Admin"
Role.find_or_create_by_name :name => "Super Admin"

# ConflictType.find_or_create_by_name :name => "Gender Based Violence"
# ConflictType.find_or_create_by_name :name => "Casted Based Violence"
# ConflictType.find_or_create_by_name :name => "Political Violence"
# ConflictType.find_or_create_by_name :name => "Inter-personal Conflict"
# ConflictType.find_or_create_by_name :name => "Resource Based Violence"

# ConflictState.find_or_create_by_name :name => "Before The Conflict"
# ConflictState.find_or_create_by_name :name => "After The Conflict"

# ConflictIntensity.find_or_create_by_name :name => "Low"
# ConflictIntensity.find_or_create_by_name :name => "Moderate"
# ConflictIntensity.find_or_create_by_name :name => "High"

Setting.find_or_create_by_id!( :id => 1, 
								:interval_alert => 2, 
								:message_success => "Success", 
								:message_invalid => "Invalid message", 
								:message_unknown => "Unknown reported field", 
								:message_invalid_sender => "Invalid sender",
								:message_duplicate => "Report with duplicate information",
								:message_failed => "Report to System failed. We will check it soon."
								);

