require 'rails_helper'

RSpec.describe Api::V1::OrganizationsController, type: :controller do
  
  let!(:user) { create :admin }
  let(:org) { create :organization_basic }
  let(:request_headers) { {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token} }

  it "must be logged in to call index" do
    get :index, format: :json
    expect(response.code).to eq("401")
  end

  it "gets a list of all the orgs" do
    user.viewable_organizations << org 
    org_count = user.viewable_organizations.count

    #LOGIN
    request.headers.merge!(request_headers) 
    get :index, format: :json
    body = JSON.parse(response.body)

    expect(body["data"].count).to eq(org_count)
    expect(body["data"].count).to be > 0
  end


end