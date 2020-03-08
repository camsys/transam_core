require 'rails_helper'

RSpec.describe Api::V1::AssetsController, type: :controller do
  
  let!(:user) { create :admin }
  let(:request_headers) { {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token} }
  let(:my_bus) {create :buslike_asset }

  it "must be logged in to call index" do
    get :index, format: :json
    expect(response.code).to eq("401")
  end

  it "must be logged in to call show" do
    get :show, params: { id: 'THISDOESNTMATTER'}, format: :json
    expect(response.code).to eq("401")
  end

  it "returns an asset" do
    #LOGIN
    request.headers.merge!(request_headers) 

    bus = my_bus
    get :show, params: { id: bus.object_key}, format: :json
    response_body = JSON.parse(response.body)
    expect(response_body["data"]["object_key"]).to eq(bus.object_key) 
  end

  
end