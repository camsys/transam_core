require 'rails_helper'

RSpec.describe Api::V1::AssetTypesController, type: :controller do
  
  let!(:user) { create :admin }
  let(:request_headers) { {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token} }
  let(:vehicle) { create :asset_type}

  it "must be logged in to work" do
    get :index, format: :json
    expect(response.code).to eq("401")
  end

  it "returns an index of asset_types" do
    vehicle_name = vehicle.name

    request.headers.merge!(request_headers) # Send user email and token headers
    get :index, format: :json
    expect(response).to be_success

    response_body = JSON.parse(response.body)
    expect(response_body["data"].first["name"]).to eq(vehicle_name) 
    
  end
  
  
end