require 'spec_helper'

describe User do

  context "Create user" do
    let!(:user) { User.make :phone_number => '85592811844' }
    before(:each) do
  		@admin_role = Role.create!({:name => "Admin"})
  		@superadmin_role = Role.create!({:name => "Super Admin"})
  	end

  	it "should have to role" do
  		Role.all.size.should == 2
  		Role.first.name.should == "Admin"
  		Role.last.name.should == "Super Admin"
  	end

    it "should not allow to add a new user with duplicate phone" do
      user2 = User.make
      User.create(:email => 'test@instedd.org', :password => '123', :phone_number => '85592811844').should_not be_valid
    end

    it "should return admin if user have admin role" do
    	user = User.create!(:email => 'test@instedd.org', :password => '12367865', :phone_number => '85592811899', :role_id => @admin_role.id)
    	user.is_admin?().should == true
  	end

  	it "should return admin if user have admin role" do
      	user = User.create!(:email => 'test@instedd.org', :password => '12398769', :phone_number => '85592811899', :role_id => @superadmin_role.id)
      	user.is_super_admin?().should == true
  	end
  end
end
