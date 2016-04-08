require 'rails_helper'

RSpec.describe DashboardsController, :type => :controller do

  before(:each) do
    sign_in create(:admin)
  end

  it 'GET index' do
    get :index

    expect(assigns(:organization)).not_to be nil
  end
end
