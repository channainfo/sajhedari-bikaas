require '../spec_helper'
require 'reporter'

describe Reporter do
	it "should create reporter" do
		Reporter.create(:first_name => "foo", :last_name => "bar", :phone_number => "85512602682").should be_valid
	end

	it "is invalid without firstname" do
		Reporter.create(:first_name => nil, :last_name => "bar", :phone_number => "85512602682").should be_invalid
	end

	it "is invalid without lastname" do
		Reporter.create(:first_name => "foo", :last_name => nil, :phone_number => "85512602682").should be_invalid
	end

	it "is invalid when phonenumber dublicate" do
		Reporter.create(:first_name => "foo", :last_name => "bar", :phone_number => "85512602682")
		Reporter.create(:first_name => "foo", :last_name => "bar", :phone_number => "85512602682").should be_invalid
	end
end