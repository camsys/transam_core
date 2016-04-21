require 'rails_helper'

RSpec.describe ImagesController, :type => :controller do

  let(:test_user) { create(:admin) }
  let(:bus) { create(:buslike_asset) }

  before(:each) do
    Organization.destroy_all
    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  it 'GET index' do
    test_image = create(:image, :imagable_id => bus.id)
    bus.images << test_image
    bus.save!
    get :index, :asset_id => bus.object_key
    bus.reload

    expect(assigns(:imagable)).to eq(bus)
    expect(assigns(:images)).to include(test_image)
  end

  it 'GET new' do
    get :new, :inventory_id => bus.object_key

    expect(assigns(:imagable)).to eq(bus)
    expect(assigns(:image).to_json).to eq(Image.new.to_json)
  end

  it 'GET edit' do
    test_image = create(:image, :imagable_id => bus.id)
    bus.images << test_image
    bus.save!
    get :edit, {:inventory_id => bus.object_key, :id => test_image.object_key}

    expect(assigns(:imagable)).to eq(bus)
    expect(assigns(:image)).to eq(test_image)
  end

  it 'POST create' do
    request.env["HTTP_REFERER"] = root_path
    Image.destroy_all
    post :create, {:inventory_id => bus.object_key, :image => attributes_for(:image)}
    bus.reload

    expect(assigns(:imagable)).to eq(bus)
    expect(bus.images.count).to eq(1)
  end

  it 'POST update' do
    test_image = create(:image, :imagable_id => bus.id)
    bus.images << test_image
    bus.save!
    post :update, {:inventory_id => bus.object_key, :id => test_image.object_key, :image => {:description => 'Test image2'}}
    test_image.reload

    expect(test_image.description).to eq('Test image2')
  end

  it 'DELETE destroy' do
    request.env["HTTP_REFERER"] = root_path
    test_image = create(:image, :imagable_id => bus.id)
    bus.images << test_image
    bus.save!
    delete :destroy, {:inventory_id => bus.object_key, :id => test_image.object_key}

    expect(Image.find_by(:object_key => test_image.object_key)).to be nil
  end

end
