require 'spec_helper'

describe "cases/show" do
  before(:each) do
    @case = assign(:case, stub_model(Case,
      :message => "Message",
      :conflict_type => nil,
      :conflict_intensity => nil,
      :conflict_state => nil,
      :location => nil,
      :user_id => "User",
      :site_id => "Site"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Message/)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(/User/)
    rendered.should match(/Site/)
  end
end
