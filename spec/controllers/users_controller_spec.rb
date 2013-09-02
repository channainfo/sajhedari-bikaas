require 'spec_helper'

describe UsersController do
	include Devise::TestHelpers

	let!(:user) { User.make(first_name => 'Jonh', :last_name => 'Nagor', :phone_number => '85512345678', :email => 'johnnagor@fakeprofile.com', :password => '123456', :password_confirmation => '123456', :role_id => Role.first) }
	before(:each) do
		sign_in user 
		@admin_role = Role.create!(:name => "Admin")
		@superadmin_role = Role.create!(:name => "Super Admin")
		User.any_instance.stub(:create_to_resourcemap).and_return(true)
	end
	it 'should have role Super Admin' do
		Role.first.should == @admin_role
		Role.all.size.should == 2
	end

	it 'should create a User' do
		user_params = {:user => {:first_name => 'Jonh', :last_name => 'Nagor', :phone_number => '85512345678', :email => 'johnnagor@fakeprofile.com', :password => '123456', :password_confirmation => '123456', :role_id => Role.first}}
		expect{post :register, user_params}.to change{User.all.size}.by(1)			
	end

	it 'should update user password' do
		put :update_password 
		response.should be_success
	end
end
