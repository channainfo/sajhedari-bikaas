# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin_role = Role.find_or_create_by_name :name => "Admin"
super_admin_role = Role.find_or_create_by_name :name => "Super Admin"


user = User.create :email => 'super@shd.org', :password => '123456', :role_id => super_admin_role.id

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

