require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:test_user) { create(:normal_user) }
  let(:email) {test_user.email}
  let(:pw) { attributes_for(:user)[:password] }

  let(:valid_headers) { {"X-User-Email" => test_user.email, "X-User-Token" => test_user.authentication_token} }

  describe "user sign in" do

    before { post "/api/v1/sign_in.json", params: {email: email, password: pw} }

    context 'good password' do
      it 'signs in an existing user' do
        expect(response).to be_successful
        
        # Expect a session hash with an email and auth token
        expect(json["data"]["session"]["email"]).to eq(email)
        expect(json["data"]["session"]["authentication_token"]).to eq(test_user.authentication_token)  
      end
    end
    
    context 'bad password' do
      let (:pw) { "somerandombadpw" }
      it 'requires password for sign in' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'locks out user after configured number of attempts', :skip => true do
      
      wrong_pw = "somerandombadpw"

      expect(test_user.access_locked?).to be false
      expect(test_user.failed_attempts).to eq(0)
      
      (1..User.maximum_attempts).each do |idx|
        post "/api/v1/sign_in.json", 
          params: { email: test_user.email, password: wrong_pw }
        
        test_user.reload
        expect(test_user.access_locked?).to be (idx == User.maximum_attempts)
        expect(test_user.failed_attempts).to eq(idx) # first try was correct
      end
      
      # Last attempt (with correct pw)
      post "/api/v1/sign_in.json", 
        params: { email: test_user.email, password: attributes_for(:user)[:password] }
      expect(response).to have_http_status(:unauthorized)
    end
  end
  
  describe "user sign out" do

    it 'signs out a user' do
      original_auth_token = test_user.authentication_token
      
      delete "/api/v1/sign_out.json",
           headers: valid_headers
    
      expect(response).to be_successful
      
      # Expect user to have a new auth token after sign out
      test_user.reload
      expect(test_user.authentication_token).not_to eq(original_auth_token)
    end
  end
  
end

