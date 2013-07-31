require 'spec_helper'

describe "media/index" do
  before(:each) do
    assign(:media, [
      stub_model(Medium,
        :name => "Name",
        :country => "Country",
        :country_code => "Country Code",
        :url => "Url",
        :display_name => "Display Name",
        :working => false
      ),
      stub_model(Medium,
        :name => "Name",
        :country => "Country",
        :country_code => "Country Code",
        :url => "Url",
        :display_name => "Display Name",
        :working => false
      )
    ])
  end

  it "renders a list of media" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Country".to_s, :count => 2
    assert_select "tr>td", :text => "Country Code".to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => "Display Name".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
