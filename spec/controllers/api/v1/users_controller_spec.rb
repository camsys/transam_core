require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do

  describe "GET #profile" do
    it "returns http success" do
      get :profile
      expect(response).to have_http_status(:success)
    end
  end

end
