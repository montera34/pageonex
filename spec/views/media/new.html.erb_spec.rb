require 'spec_helper'

describe "media/new" do
  before(:each) do
    assign(:medium, stub_model(Medium,
      :name => "MyString",
      :country => "MyString",
      :country_code => "MyString",
      :url => "MyString",
      :display_name => "MyString",
      :working => false
    ).as_new_record)
  end

  it "renders new medium form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", media_path, "post" do
      assert_select "input#medium_name[name=?]", "medium[name]"
      assert_select "input#medium_country[name=?]", "medium[country]"
      assert_select "input#medium_country_code[name=?]", "medium[country_code]"
      assert_select "input#medium_url[name=?]", "medium[url]"
      assert_select "input#medium_display_name[name=?]", "medium[display_name]"
      assert_select "input#medium_working[name=?]", "medium[working]"
    end
  end
end
