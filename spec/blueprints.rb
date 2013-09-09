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

Role.blueprint do
  name {Sham.name}
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
  code { Sham.name }
  name { Sham.location_name }
  lat { rand(180) - 90 }
  lng { rand(360) - 180 }
end

ConflictCase.blueprint do
  
end