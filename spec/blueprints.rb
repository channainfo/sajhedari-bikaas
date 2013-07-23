require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.location_name {|i| "location #{i}" }
Sham.user_name {|i| "user #{i}" }
Sham.name {|i| "user #{i}" }
Sham.phone_number { Faker::PhoneNumber.phone_number }
Sham.email do
 "add#{(1..8).map { rand(1000).to_i }.join}@yahoo.com"
end

User.blueprint do
	first_name { Sham.user_name }
  last_name { Sham.user_name}
	password { "password" }
  email { Sham.email }
	phone_number { Sham.phone_number }
end

Reporter.blueprint do
  first_name { Sham.user_name }
  last_name { Sham.user_name}
  phone_number { Sham.phone_number }
end

Location.blueprint do
  code
  name { Sham.location_name }
  lat
  lng
end