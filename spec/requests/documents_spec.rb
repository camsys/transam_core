require 'rails_helper'

RSpec.describe Api::V1::DocumentsController, type: :request do
  let(:test_user) { create(:normal_user) }
  let(:test_org) { create(:organization_basic) }
  let(:test_asset) { create(:buslike_asset_basic_org, organization: test_org) }
  let(:test_file) { Rack::Test::UploadedFile.new('spec/files/sample.png', 'application/png', true) }

  let(:valid_headers) { {"X-User-Email" => test_user.email, "X-User-Token" => test_user.authentication_token} }

  describe 'POST /api/v1/assets/{asset_id}/documents' do

    it "alerts if asset not found" do 
      post "/api/v1/assets/INVALID_ASSET_KEY/documents.json", headers: valid_headers
      expect(response).to have_http_status(:not_found)
    end

    context "uploads document" do 
      it "succeed" do 
        params = { document: test_file, description: "test document" }
        post "/api/v1/assets/#{test_asset.object_key}/documents.json", headers: valid_headers, params: params

        expect(response).to have_http_status(:success)
        expect(json["data"]['document']["object_key"]).not_to be_empty
      end

      it "fail" do 
        path = 'spec/files/sample.png'
        post "/api/v1/assets/#{test_asset.object_key}/documents.json", headers: valid_headers

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'GET /api/v1/assets/{asset_id}/documents' do

    it "succeed" do 
      get "/api/v1/assets/#{test_asset.object_key}/documents.json", headers: valid_headers

      expect(response).to have_http_status(:success)
      expect(json["data"]["documents"].size).to eq(test_asset.documents.size)
    end

  end

  describe 'PATCH /api/v1/assets/{asset_id}/documents/{id}' do

    it "succeed" do 
      test_asset.documents.clear
      # upload one
      params = { document: test_file, description: "test document" }
      post "/api/v1/assets/#{test_asset.object_key}/documents.json", headers: valid_headers, params: params
      
      # update it
      test_asset.reload
      new_description = "updated test document"
      new_params = { description: new_description }
      patch "/api/v1/assets/#{test_asset.object_key}/documents/#{test_asset.documents.first.object_key}.json", headers: valid_headers, params: new_params

      expect(response).to have_http_status(:success)
      expect(json["data"]['document']["description"]).to eq(new_description)
    end

  end

  describe 'DELETE /api/v1/assets/{asset_id}/documents/{id}' do

    it "succeed" do 
      test_asset.documents.clear
      # upload one
      params = { document: test_file, description: "test document" }
      post "/api/v1/assets/#{test_asset.object_key}/documents.json", headers: valid_headers, params: params
      
      # delete it
      test_asset.reload
      delete "/api/v1/assets/#{test_asset.object_key}/documents/#{test_asset.documents.first.object_key}.json", headers: valid_headers

      expect(response).to have_http_status(:success)
      test_asset.reload
      expect(test_asset.documents).to be_empty
    end

  end
end

