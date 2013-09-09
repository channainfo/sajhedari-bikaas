require 'spec_helper'

describe Location do
  context "Create location" do
    before(:each) do
      @location = Location.make :code => 'AA', :name => 'Location 1', :lat => '11.2345643333', :lng => '124.384877889'
      @conflict = ConflictCase.make :location_id => @location.id
    end

  	it "should failed to save when location code is duplicate" do
      Location.create(:code => 'AA', :name => 'Location 2', :lat => '14.5425425422', :lng => '114.674433444').should_not be_valid
  	end

    it "should return latlng" do
      @location.lnglat().should == "124.384877889,11.2345643333"
    end

    it "should return its description" do
      @location.description.should == @location.name + "(" + @location.code + ")"
    end

    it "should present in the conflict" do
      @location.never_present_in_conflict.should == false
    end

    it "should never present in the conflict" do
      l = Location.create!(:code => 'AB', :name => 'Location 2', :lat => '14.5425425422', :lng => '114.674433444')
      l.never_present_in_conflict.should  == true
    end
  end
end
