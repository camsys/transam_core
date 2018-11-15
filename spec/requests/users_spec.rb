require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:test_user) { create(:normal_user) }
  let(:email) {test_user.email}

  before(:each) do
    test_user.organizations = [test_user.organization]
    test_user.viewable_organizations = [test_user.organization]
    test_user.save!
  end

  describe 'GET /api/v1/users/profile' do

    before { get "/api/v1/users/profile.json?email=#{email}" }

    context 'when the record exists' do
      it 'returns user profile' do
        expect(response).to render_template(:profile)
        expect(json).not_to be_empty
        expect(json['data']['email']).to eq(email)
        expect(json['status']).to eq('success')
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
end
