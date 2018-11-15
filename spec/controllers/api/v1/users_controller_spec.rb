require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do

  describe "GET #profile" do
    it "returns http not found" do
      get :profile, format: :json
      expect(response).to have_http_status(:not_found)
    end
  end

end
