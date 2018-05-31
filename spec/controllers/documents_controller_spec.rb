require 'rails_helper'

RSpec.describe DocumentsController, :type => :controller do

  let(:test_user) { create(:admin) }
  let(:bus) { create(:buslike_asset) }

  before(:each) do
    test_user.organizations << test_user.organization
    test_user.viewable_organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  it 'GET index' do
    test_document = create(:document, :documentable_id => bus.id)
    bus.documents << test_document
    bus.save!
    get :index, params: {:asset_id => bus.object_key}
    bus.reload

    expect(assigns(:documentable)).to eq(bus)
    expect(assigns(:documents)).to include(test_document)
  end

  it 'GET new' do
    get :new, params: {:inventory_id => bus.object_key}

    expect(assigns(:documentable)).to eq(bus)
    expect(assigns(:document).to_json).to eq(Document.new.to_json)
  end

  it 'GET edit' do
    test_document = create(:document, :documentable_id => bus.id)
    bus.documents << test_document
    bus.save!
    get :edit, params: {:inventory_id => bus.object_key, :id => test_document.object_key}

    expect(assigns(:documentable)).to eq(bus)
    expect(assigns(:document)).to eq(test_document)
  end

  it 'POST create' do
    request.env["HTTP_REFERER"] = root_path
    Document.destroy_all
    post :create, params: {:inventory_id => bus.object_key, :document => attributes_for(:document)}
    bus.reload

    expect(assigns(:documentable)).to eq(bus)
    expect(bus.documents.count).to eq(1)
  end

  it 'POST update' do
    test_document = create(:document, :documentable_id => bus.id)
    bus.documents << test_document
    bus.save!
    post :update, params: {:inventory_id => bus.object_key, :id => test_document.object_key, :document => {:description => 'Test document2'}}
    test_document.reload

    expect(test_document.description).to eq('Test document2')
  end

  it 'DELETE destroy' do
    request.env["HTTP_REFERER"] = root_path
    test_document = create(:document, :documentable_id => bus.id)
    bus.documents << test_document
    bus.save!
    delete :destroy, params: {:inventory_id => bus.object_key, :id => test_document.object_key}

    expect(Document.find_by(:object_key => test_document.object_key)).to be nil
  end

end
