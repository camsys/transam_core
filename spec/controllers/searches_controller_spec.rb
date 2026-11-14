require 'rails_helper'

# TTPLAT-3118: pins SearchesController#keyword, the navbar keyword search
# (shared/_header.html.haml posts search_text to keyword_searches_path). The
# new/create actions are not covered here; see the Stage A report.
RSpec.describe SearchesController, :type => :controller do
  render_views

  let(:test_user) { create(:admin) }

  # keyword_search_indices is not in DatabaseCleaner's truncation list and rows
  # outlive the example, so clear it on both sides to keep totals exact.
  before(:each) { KeywordSearchIndex.delete_all }
  after(:each)  { KeywordSearchIndex.delete_all }

  before(:each) do
    test_user.organizations << test_user.organization
    test_user.viewable_organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  let!(:matching_row) do
    create(:keyword_search_index, :organization => test_user.organization, :object_key => 'KEYMATCH0001',
           :search_text => 'alpha widget', :summary => 'Matching summary')
  end
  let!(:other_row) do
    create(:keyword_search_index, :organization => test_user.organization, :object_key => 'KEYOTHER0001',
           :search_text => 'beta gadget', :summary => 'Other summary')
  end

  def json_rows
    JSON.parse(response.body)
  end

  describe 'GET keyword as HTML' do
    it 'finds the row matching the term and not the other' do
      get :keyword, params: {:search_text => 'alpha'}

      expect(response).to have_http_status(:ok)
      expect(assigns(:keyword_search_results)).to contain_exactly(matching_row)
      # The page body carries the count; the rows themselves load through the JSON branch
      expect(response.body).to include('1 found.')
      expect(response.body).to include("var search_text = 'alpha'")
    end
  end

  describe 'GET keyword as JSON' do
    it 'returns the matching row only' do
      get :keyword, params: {:search_text => 'alpha'}, format: :json
      body = json_rows

      expect(response).to have_http_status(:ok)
      expect(body['total']).to eq(1)
      expect(body['rows'].size).to eq(1)
      expect(body['rows'].first['content']).to include('Matching summary')
      expect(body['rows'].first['content']).to include('KEYMATCH0001')
      expect(response.body).not_to include('Other summary')
    end

    it 'ORs comma-separated terms' do
      get :keyword, params: {:search_text => 'alpha, gadget'}, format: :json

      expect(json_rows['total']).to eq(2)
    end

    it 'returns no rows for a one-character term' do
      get :keyword, params: {:search_text => 'a'}, format: :json

      expect(response).to have_http_status(:ok)
      expect(json_rows['total']).to eq(0)
      expect(json_rows['rows']).to eq([])
    end

    it 'returns no rows for a blank term' do
      get :keyword, params: {:search_text => ''}, format: :json

      expect(response).to have_http_status(:ok)
      expect(json_rows['total']).to eq(0)
      expect(json_rows['rows']).to eq([])
    end

    it 'does not return a row from an organization the user cannot see' do
      hidden_org = create(:organization)
      create(:keyword_search_index, :organization => hidden_org, :object_key => 'KEYHIDDEN001',
             :search_text => 'alpha hidden', :summary => 'Hidden summary')

      get :keyword, params: {:search_text => 'alpha'}, format: :json

      expect(json_rows['total']).to eq(1)
      expect(response.body).not_to include('Hidden summary')
    end
  end

end
