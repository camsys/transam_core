require 'rails_helper'

RSpec.describe ImagesController, :type => :controller do

  let(:test_user) { create(:admin) }
  let(:bus) { create(:buslike_asset) }

  before(:each) do
    Organization.destroy_all
    test_user.organizations << test_user.organization
    test_user.viewable_organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  # The asset Photos tab reads its rows from this branch (shared/_images.html.haml)
  it 'GET index as JSON for a global_base_imagable returns only that imagable\'s images' do
    other_bus = create(:buslike_asset)
    bus_image = create(:image, :base_imagable => bus, :imagable => bus)
    create(:image, :base_imagable => other_bus, :imagable => other_bus)

    get :index, params: {:global_base_imagable => bus.to_global_id.to_s}, format: :json
    body = JSON.parse(response.body)

    expect(response).to have_http_status(:ok)
    expect(assigns(:imagable)).to eq(bus)
    expect(body['total']).to eq(1)
    expect(body['rows'].map { |row| row['object_key'] }).to eq([bus_image.object_key])
  end

  it 'GET new' do
    get :new, params: {:inventory_id => bus.object_key}

    expect(assigns(:imagable)).to eq(bus)
    expect(assigns(:image).to_json).to eq(Image.new.to_json)
  end

  it 'GET edit' do
    test_image = create(:image, :imagable_id => bus.id)
    bus.images << test_image
    bus.save!
    get :edit, params: {:inventory_id => bus.object_key, :id => test_image.object_key}

    expect(assigns(:imagable)).to eq(bus)
    expect(assigns(:image)).to eq(test_image)
  end

  it 'POST create' do
    request.env["HTTP_REFERER"] = root_path
    Image.destroy_all
    post :create, params: {:inventory_id => bus.object_key, :image => attributes_for(:image)}
    bus.reload

    expect(assigns(:imagable)).to eq(bus)
    expect(bus.images.count).to eq(1)
  end

  it 'POST update' do
    test_image = create(:image, :imagable_id => bus.id)
    bus.images << test_image
    bus.save!
    post :update, params: {:inventory_id => bus.object_key, :id => test_image.object_key, :image => {:description => 'Test image2'}}
    test_image.reload

    expect(test_image.description).to eq('Test image2')
  end

  it 'DELETE destroy' do
    request.env["HTTP_REFERER"] = root_path
    test_image = create(:image, :imagable_id => bus.id)
    bus.images << test_image
    bus.save!
    delete :destroy, params: {:inventory_id => bus.object_key, :id => test_image.object_key}

    expect(Image.find_by(:object_key => test_image.object_key)).to be nil
  end

end
