require 'spec_helper'

describe "users/index" do
  before(:each) do
    assign(:users, [
      stub_model(User),
      stub_model(User)
    ])
  end

  it "renders a list of users" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
