require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:test_user) { create(:normal_user) }
  let(:email) {test_user.email}
  let(:organization_id) {test_user.organization_id}

  let(:valid_headers) { {"X-User-Email" => test_user.email, "X-User-Token" => test_user.authentication_token} }

  before(:each) do
    test_user.organizations = [test_user.organization]
    test_user.viewable_organizations = [test_user.organization]
    test_user.save!
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

