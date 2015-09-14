require 'rails_helper'

RSpec.describe VendorsController, :type => :controller do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_user) { create(:admin) }

  before(:each) do

    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  it 'GET index' do
    test_vendor = create(:vendor, :organization => subject.current_user.organization)
    get :index

    expect(assigns(:vendors)).to include(test_vendor)
  end

  it 'GET filter' do
    test_vendor = create(:vendor, :organization => subject.current_user.organization)
    get :filter, :query => test_vendor.name, :format => :json

    expect(JSON.parse(response.body)).to include({"id" => test_vendor.id, "name" => test_vendor.name})
  end

  it 'GET show' do
    test_vendor = create(:vendor, :organization => subject.current_user.organization)
    get :show, :id => test_vendor.object_key

    expect(assigns(:vendor)).to eq(test_vendor)
  end

  it 'GET new' do
    get :new

    expect(assigns(:vendor).to_json).to eq(Vendor.new.to_json)
  end

  it 'GET edit' do
    test_vendor = create(:vendor, :organization => subject.current_user.organization)
    get :edit, :id => test_vendor.object_key

    expect(assigns(:vendor)).to eq(test_vendor)
  end

  it 'POST create' do
    post :create, :vendor => attributes_for(:vendor, :name => 'vendor name2', :organization_id => subject.current_user.organization_id)

    expect(assigns(:vendor).name).to eq('vendor name2')
  end

  it 'POST update' do
    test_vendor = create(:vendor, :organization => subject.current_user.organization)

    post :update, :id => test_vendor.object_key, :vendor => {:name => 'vendor name3'}
    test_vendor.reload

    expect(test_vendor.name).to eq('vendor name3')
  end

  it 'DELETE destroy' do
    test_vendor = create(:vendor, :organization => subject.current_user.organization)

    delete :destroy, :id => test_vendor.object_key

    expect(Vendor.find_by(:object_key => test_vendor.object_key)).to be nil
  end

end
