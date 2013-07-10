require 'spec_helper'

describe "cases/index" do
  before(:each) do
    assign(:cases, [
      stub_model(Case,
        :message => "Message",
        :conflict_type => nil,
        :conflict_intensity => nil,
        :conflict_state => nil,
        :location => nil,
        :user_id => "User",
        :site_id => "Site"
      ),
      stub_model(Case,
        :message => "Message",
        :conflict_type => nil,
        :conflict_intensity => nil,
        :conflict_state => nil,
        :location => nil,
        :user_id => "User",
        :site_id => "Site"
      )
    ])
  end

  it "renders a list of cases" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Message".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "User".to_s, :count => 2
    assert_select "tr>td", :text => "Site".to_s, :count => 2
  end
end
