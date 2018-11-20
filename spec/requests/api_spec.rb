require 'rails_helper'

RSpec.describe Api::ApiController, type: :request do
  let(:test_user) { create(:normal_user) }

  let(:valid_headers) { {"X-User-Email" => test_user.email, "X-User-Token" => test_user.authentication_token} }
  let(:invalid_headers) { {"X-User-Email" => test_user.email, "X-User-Token" => "INVALID_TOKEN"} }
  let(:incomplete_headers) { {"X-User-Email" => test_user.email} }

  context 'User authentication' do
    
    it 'authenticates registered user if valid auth headers are passed' do
      get "/api/touch_session.json",
           headers: valid_headers

      expect(response).to be_successful
    end
    
    it 'throws 401 error if invalid auth headers are passed' do
      get "/api/touch_session.json",
           headers: invalid_headers

      expect(response).to have_http_status(:unauthorized)
    end
    
    it 'throws 401 error if username only is passed' do
      get "/api/touch_session.json",
           headers: incomplete_headers

      expect(response).to have_http_status(:unauthorized)
    end
    
    it 'throws 401 error if no auth headers are passed' do
      get "/api/touch_session.json"
      expect(response).to have_http_status(:unauthorized)
    end
      
  end
  
end

