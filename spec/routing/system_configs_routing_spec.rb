require "rails_helper"

RSpec.describe SystemConfigsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/system_configs").to route_to("system_configs#index")
    end

    it "routes to #new" do
      expect(:get => "/system_configs/new").to route_to("system_configs#new")
    end

    it "routes to #show" do
      expect(:get => "/system_configs/1").to route_to("system_configs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/system_configs/1/edit").to route_to("system_configs#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/system_configs").to route_to("system_configs#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/system_configs/1").to route_to("system_configs#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/system_configs/1").to route_to("system_configs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/system_configs/1").to route_to("system_configs#destroy", :id => "1")
    end
  end
end
