require 'rails_helper'

RSpec.describe Api::V1::AssetEventsController, type: :request do
  let(:test_user) { create(:normal_user) }
  let(:test_asset) { create(:transam_asset) }
  let(:asset_object_key) { test_asset.object_key }
  let(:test_event) { create(:condition_update_event) }
  let(:event_object_key) { test_event.object_key }

  let(:valid_headers) { {"X-User-Email" => test_user.email, "X-User-Token" => test_user.authentication_token} }

  describe 'POST /api/v1/asset_events' do

    context 'testing type of test asset' do
      it 'is a transam asset' do 
        expect(test_asset).to be_a(TransamAsset)
      end
    end

    context 'when valid params are passed' do
      before { post "/api/v1/asset_events.json", params: { asset_object_key: asset_object_key, asset_event_type_id: AssetEventType.find_by(name: 'Condition').id, assessed_rating: 2 }, headers: valid_headers }

      it 'creates and returns an asset event' do
        expect(json).not_to be_empty
        expect(json['status']).to eq('success')

        expect(json['data']['assessed_rating']).to eq('2.0')
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the asset does not exist' do
      let(:asset_object_key) { 'INVALID_KEY' }
      before { post "/api/v1/asset_events.json", params: { asset_object_key: asset_object_key, event_type: 'Condition', assessed_rating: 2 }, headers: valid_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json['status']).to eq('fail')
        expect(json['message']).to match(/not found/)
      end
    end
  end

  describe 'PUT /api/v1/asset_events/{id}' do

    context 'when valid params are passed' do
      before { put "/api/v1/asset_events/#{event_object_key}.json", params: { assessed_rating: 3.2 }, headers: valid_headers }

      it 'updates and returns the asset event' do
        expect(json).not_to be_empty
        expect(json['status']).to eq('success')
        expect(json['data']['assessed_rating']).to eq('3.2')
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the event does not exist' do
      let(:event_object_key) { 'INVALID_KEY' }
      before { put "/api/v1/asset_events/#{event_object_key}.json", params: { assessed_rating: 3.2 }, headers: valid_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json['status']).to eq('fail')
        expect(json['message']).to match(/not found/)
      end
    end
  end

  describe 'DELETE /api/v1/asset_events/{id}' do

    context 'when the event exists' do
      before { delete "/api/v1/asset_events/#{event_object_key}.json", headers: valid_headers }

      it 'destroys the event' do
        expect(json).not_to be_empty
        expect(json['status']).to eq('success')
        expect(AssetEvent.where(object_key: event_object_key)).not_to exist
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the event does not exist' do
      let(:event_object_key) { 'INVALID_KEY' }
      before { delete "/api/v1/asset_events/#{event_object_key}.json", headers: valid_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json['status']).to eq('fail')
        expect(json['message']).to match(/not found/)
      end
    end
  end
end