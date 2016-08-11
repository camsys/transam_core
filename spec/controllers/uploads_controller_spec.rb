require 'rails_helper'

RSpec.describe UploadsController, :type => :controller do

  before(:each) do
    test_user = create(:admin)
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  let(:test_upload) { create(:upload) }

  it 'GET index' do
    test_upload.update!(:organization => subject.current_user.organization)
    test_upload2 = create(:upload)
    get :index

    expect(assigns(:uploads)).to include(test_upload)
    expect(assigns(:uploads)).not_to include(test_upload2)
  end

  it 'GET show' do
    get :show, :id => test_upload.object_key

    expect(assigns(:upload)).to eq(test_upload)
  end
  it 'GET undo' do
    get :undo, :id => test_upload.object_key
    test_upload.reload

    expect(assigns(:upload)).to eq(test_upload)
    expect(test_upload.force_update).to be false
    expect(test_upload.file_status_type).to eq(FileStatusType.find_by(:name => 'Reverted'))
  end

  it 'GET templates' do
    test_asset = create(:buslike_asset, :organization => subject.current_user.organization)
    get :templates

    expect(assigns(:message)).to eq("Creating inventory template. This process might take a while.")
    expect(assigns(:asset_types)).to include({id: test_asset.asset_type.id, name: test_asset.asset_type.to_s, class_name: test_asset.asset_type.class_name, orgs: [test_asset.organization_id]})
  end

  it 'GET new' do
    get :new

    expect(assigns(:upload).to_json).to eq(Upload.new.to_json)
  end
  it 'POST create' do
    post :create, :upload => attributes_for(:upload)

    expect(assigns(:upload).user).to eq(subject.current_user)
    expect(assigns(:upload).file_content_type_id).to eq(1)
    expect(assigns(:upload).force_update).to be false
  end
  it 'DELETE destroy' do
    delete :destroy, :id => test_upload.object_key

    expect(Upload.find_by(:object_key => test_upload.object_key)).to be nil
  end
end
