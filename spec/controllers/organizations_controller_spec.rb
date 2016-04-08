require 'rails_helper'

RSpec.describe OrganizationsController, :type => :controller do

  before(:each) do
    test_user = create(:admin)
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  let(:test_org) { create(:organization) }

  it 'GET index' do
    get :index

    expect(assigns(:organizations)).to include(subject.current_user.organization)
  end

  describe 'GET show' do
    it 'by short name' do
      get :show, :id => test_org.short_name

      expect(assigns(:org)).to eq(Organization.get_typed_organization(test_org))
    end
    it 'does not exist' do
      get :show, :id => 'ABCD'

      expect(assigns(:org)).to be nil
    end
    it 'sets assets and users' do
      test_asset = create(:buslike_asset, :organization => subject.current_user.organization)
      get :show, :id => subject.current_user.organization.short_name

      expect(assigns(:users)).to include(subject.current_user)
      expect(assigns(:total_assets)).to eq(1)
    end
  end

  it 'GET edit' do
    get :edit, :id => test_org.short_name

    expect(assigns(:org)).to eq(Organization.get_typed_organization(test_org))
    expect(assigns(:page_title)).to eq("Update: #{test_org.name}")
  end

  it 'PUT update' do
    put :update, :id => test_org.short_name, :organization => {:name => 'new org name'}
    test_org.reload

    expect(assigns(:org)).to eq(Organization.get_typed_organization(test_org))
    expect(test_org.name).to eq('new org name')
  end
end
