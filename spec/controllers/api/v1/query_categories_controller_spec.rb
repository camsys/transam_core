require 'rails_helper'

RSpec.describe Api::V1::QueryCategoriesController, type: :controller do
  
  let!(:user) { create :admin }
  let(:request_headers) { {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token} }

  it "must be logged in to work" do
    get :index, format: :json
    expect(response.code).to eq("401")
  end

  it "returns all the query filters " do
    # Setup
    first_query_category = QueryCategory.order(:name).first 
    number_of_query_categories = QueryCategory.all.count
    
    # Make the call and unpack
    request.headers.merge!(request_headers) # Send user email and token headers
    get :index, format: :json
    expect(response).to be_success
    response_body = JSON.parse(response.body)
    
    # Tests
    first_response = (response_body["data"].sort_by { |qc| qc["name"] }).first
    expect(first_response["name"]).to eq(first_query_category.name)
    expect(response_body["data"].count).to eq(number_of_query_categories)
    
  end
  
  
end