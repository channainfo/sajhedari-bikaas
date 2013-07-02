require 'spec_helper'

describe User do

  it "should be confirmed" do
    user = User.make confirmed_at: nil
    user.confirmed?.should be_false
    user.confirm!
    user.confirmed?.should be_true
  end

  it "creates a collection" do
    user = User.make
    collection = Collection.make_unsaved
    user.create_collection(collection).should eq(collection)
    user.collections.should eq([collection])
    user.memberships.first.should be_admin
  end  
end
