require "spec_helper"

describe MediaController do
  describe "routing" do

    it "routes to #index" do
      get("/media").should route_to("media#index")
    end

    it "routes to #new" do
      get("/media/new").should route_to("media#new")
    end

    it "routes to #show" do
      get("/media/1").should route_to("media#show", :id => "1")
    end

    it "routes to #edit" do
      get("/media/1/edit").should route_to("media#edit", :id => "1")
    end

    it "routes to #create" do
      post("/media").should route_to("media#create")
    end

    it "routes to #update" do
      put("/media/1").should route_to("media#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/media/1").should route_to("media#destroy", :id => "1")
    end

  end
end
