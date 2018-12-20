require 'rails_helper'

RSpec.describe Api::V1::OrganizationsController, type: :request do
  let(:test_user) { create(:normal_user) }
  let(:org_id)    { test_user.organization_id }

  let(:valid_headers) { {"X-User-Email" => test_user.email, "X-User-Token" => test_user.authentication_token} }

  before(:each) do
    test_user.organizations = [test_user.organization]
    test_user.viewable_organizations = [test_user.organization]
    test_user.save!
  end

  describe 'GET /api/v1/organizations/{id}' do

    before { get "/api/v1/organizations/#{org_id}.json", headers: valid_headers }

    context 'when the record exists' do
      it 'returns organization profile' do
        expect(response).to render_template(:show)
        expect(json).not_to be_empty
        expect(json['status']).to eq('success')

        # test output
        expect(json['data']['organization']['id']).to eq(org_id)
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:org_id) { 'INVALID_KEY' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json['status']).to eq('fail')
        expect(json['data']['id']).to match(/not found/)
      end
    end
  end

end

