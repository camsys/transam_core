require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:test_user) { create(:normal_user) }
  let(:email) {test_user.email}
  let(:organization_id) {test_user.organization_id}
  let(:pw) { attributes_for(:user)[:password] }

  let(:valid_headers) { {"X-User-Email" => test_user.email, "X-User-Token" => test_user.authentication_token} }

  before(:each) do
    test_user.organizations = [test_user.organization]
    test_user.viewable_organizations = [test_user.organization]
    test_user.save!
  end

  describe "user sign in" do

    before { post "/api/v1/sign_in.json", params: {email: email, password: pw}, headers: valid_headers }

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
          params: { email: test_user.email, password: wrong_pw }, 
          headers: valid_headers
        
        test_user.reload
        expect(test_user.access_locked?).to be (idx == User.maximum_attempts)
        expect(test_user.failed_attempts).to eq(idx) # first try was correct
      end
      
      # Last attempt (with correct pw)
      post "/api/v1/sign_in.json", 
        params: { email: test_user.email, password: attributes_for(:user)[:password] },
        headers: valid_headers
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

  describe 'GET /api/v1/users/profile' do

    before { get "/api/v1/users/profile.json?email=#{email}", headers: valid_headers }

    context 'when the record exists' do
      it 'returns user profile' do
        expect(response).to render_template(:profile)
        expect(json).not_to be_empty
        expect(json['status']).to eq('success')

        # test output
        expect(json['data']['email']).to eq(email)
        expect(json['data'].keys).to match(["id", "name", "email", "organization"])
        expect(json['data']['organization'].keys).to match(["id", "name", "short_name"])
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:email) { 'foo@bar.baz' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json['status']).to eq('fail')
        expect(json['data']['email']).to match(/not found/)
      end
    end
  end

  describe 'GET /api/v1/users' do

    before { get "/api/v1/users.json?organization_id=#{organization_id}", headers: valid_headers }

    context 'when the record exists' do
      it 'contains user' do
        expect(response).to render_template(:index)
        expect(json).not_to be_empty
        expect(json['status']).to eq('success')

        # test output
        expect(json['data']['organization']['id']).to eq(organization_id)
        expect(json['data']['organization'].keys).to match(["id", "name", "short_name"])
        expect(json['data']['users']).to include({"id" => test_user.id, "name" => test_user.name, "email" => test_user.email})
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:organization_id) { nil }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json['status']).to eq('fail')
        expect(json['data']['organization']).to match(/not found/)
      end
    end
  end
  
end

