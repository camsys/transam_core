require 'rails_helper'

RSpec.describe ManufacturersController, :type => :controller do

  let(:test_user) { create(:admin) }
  let(:bus) { create(:buslike_asset) }
  let(:test_manufacturer) { create(:manufacturer) }

  before(:each) do
    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  it 'GET index' do
    bus.update!(:organization => subject.current_user.organization, :manufacturer => test_manufacturer)
    bus2 = create(:buslike_asset)
    get :index

    expect(assigns(:manufacturers)).to include(test_manufacturer)
    expect(assigns(:manufacturers).count).to eq(1)
    expect(test_manufacturer.assets).not_to include(bus2)
  end
end
