require 'rails_helper'

RSpec.describe AssetGroupsController, :type => :controller do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_group) { create(:asset_group) }

  before(:each) do
    sign_in create(:admin, :organization => test_group.organization)
  end

  it 'GET index' do
    get :index

    expect(assigns(:organization)).to eq(Organization.get_typed_organization(test_group.organization))
    expect(assigns(:asset_groups)).to include(test_group)
  end
  it 'GET show' do
    create(:buslike_asset, :asset_groups => [test_group])
    get :show, :id => test_group.object_key

    expect(assigns(:asset_group)).to eq(test_group)
    expect(assigns(:total_assets)).to eq(1)
  end

  it 'GET new' do
    get :new

    expect(assigns(:asset_group).to_json).to eq(AssetGroup.new.to_json)
  end
  it 'GET edit' do
    get :edit, :id => test_group.object_key

    expect(assigns(:asset_group)).to eq(test_group)
  end

  it 'POST create' do
    post :create, :asset_group => attributes_for(:asset_group, :description => 'new asset group test')

    expect(assigns(:asset_group).description).to eq('new asset group test')
    expect(assigns(:asset_group).active).to be true
    expect(assigns(:asset_group).organization).to eq(Organization.get_typed_organization(subject.current_user.organization))
  end
  it 'PUT update' do
    put :update, :id => test_group.object_key, :asset_group => {:description => 'new description'}
    test_group.reload

    expect(assigns(:asset_group)).to eq(test_group)
    expect(test_group.description).to eq('new description')
  end

  it 'DELETE destroy' do
    delete :destroy, :id => test_group.object_key

    expect(AssetGroup.find_by(:object_key => test_group.object_key)).to be nil
  end

end
