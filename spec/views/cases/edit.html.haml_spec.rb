require 'spec_helper'

describe "cases/edit" do
  before(:each) do
    @case = assign(:case, stub_model(Case,
      :message => "MyString",
      :conflict_type => nil,
      :conflict_intensity => nil,
      :conflict_state => nil,
      :location => nil,
      :user_id => "MyString",
      :site_id => "MyString"
    ))
  end

  it "renders the edit case form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", case_path(@case), "post" do
      assert_select "input#case_message[name=?]", "case[message]"
      assert_select "input#case_conflict_type[name=?]", "case[conflict_type]"
      assert_select "input#case_conflict_intensity[name=?]", "case[conflict_intensity]"
      assert_select "input#case_conflict_state[name=?]", "case[conflict_state]"
      assert_select "input#case_location[name=?]", "case[location]"
      assert_select "input#case_user_id[name=?]", "case[user_id]"
      assert_select "input#case_site_id[name=?]", "case[site_id]"
    end
  end
end
