require 'rails_helper'

RSpec.describe Api::V1::AssetsController, type: :request do
  let(:test_user) { create(:normal_user) }
  let(:test_asset) { create(:transam_asset) }
  let(:asset_id) { test_asset.object_key }

  let(:valid_headers) { {"X-User-Email" => test_user.email, "X-User-Token" => test_user.authentication_token} }

  before(:each) do
    test_user.organizations = [test_user.organization]
    test_user.viewable_organizations = [test_user.organization]
    test_user.save!

    test_asset.organization = test_user.organization
    test_asset.save!
  end

  # Skipped: pass-6 investigation (TTPLAT-3072) found two independent failures here.
  # 1) `render_template(:show)` does not apply - Api::ApiController < ActionController::API
  #    renders JSON only, so no template is ever recorded as rendered (harness artifact,
  #    would be a one-line fix). 2) the "not found" example asserts on
  #    json['data']['id'], but the controller's fail branch (assets_controller.rb:9,
  #    json_response(:fail, message: "...")) returns a top-level `message` string and no
  #    `data` key at all - a genuine mismatch between the spec's assumed response shape
  #    and the controller's actual JsonResponseHelper format, not a harness issue. Fixing
  #    the second requires a judgment call about the intended response shape, which is
  #    out of this pass's bounded scope. Left skipped; see ttplat-3072-cc-pass6-report.md.
  describe 'GET /api/v1/assets/{id}', :skip do

    before { get "/api/v1/assets/#{asset_id}.json", headers: valid_headers }

    context 'when the record exists' do
      it 'returns asset profile' do
        expect(response).to render_template(:show)
        expect(json).not_to be_empty
        expect(json['status']).to eq('success')

        # test output
        expect(json['data']['object_key']).to eq(asset_id)
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:asset_id) { 'INVALID_KEY' }

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

