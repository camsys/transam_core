require 'rails_helper'

RSpec.describe ErrorsController, :type => :controller do
  render_views
  
  it 'GET show' do
    sign_in create(:admin)
    get :show, params: {use_route: '/500'}

    expect(response.body).to include('Error 500 Application Error')
  end
end
