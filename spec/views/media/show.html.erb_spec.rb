require 'spec_helper'

describe "media/show" do
  before(:each) do
    @medium = assign(:medium, stub_model(Medium,
      :name => "Name",
      :country => "Country",
      :country_code => "Country Code",
      :url => "Url",
      :display_name => "Display Name",
      :working => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Country/)
    rendered.should match(/Country Code/)
    rendered.should match(/Url/)
    rendered.should match(/Display Name/)
    rendered.should match(/false/)
  end
end
