require 'rails_helper'

RSpec.describe UserOrganizationFiltersController, :type => :controller do

  let(:test_filter) { create(:user_organization_filter) }

  before(:each) do
    sign_in create(:normal_user)
  end

  it 'GET index' do
    get :index, :user_id => subject.current_user.object_key

    expect(assigns(:user_organization_filters)).to eq(UserOrganizationFilter.all)
  end

  it 'GET show' do
    get :show, :user_id => subject.current_user.object_key, :id => test_filter.object_key

    expect(assigns(:user_organization_filter)).to eq(test_filter)
  end

  it 'GET use' do
    request.env["HTTP_REFERER"] = root_path
    get :use, :user_id => subject.current_user.object_key, :user_organization_filter_id => test_filter.object_key

    expect(assigns(:user_organization_filter)).to eq(test_filter)
    expect(subject.current_user.user_organization_filter).to eq(test_filter)
  end

  it 'GET new' do
    get :new, :user_id => subject.current_user.object_key

    expect(assigns(:user_organization_filter).to_json).to eq(UserOrganizationFilter.new.to_json)
  end
  it 'GET edit' do
    get :edit, :user_id => subject.current_user.object_key, :id => test_filter.object_key

    expect(assigns(:user_organization_filter)).to eq(test_filter)
  end

  it 'POST create' do
    UserOrganizationFilter.destroy_all
    test_org = create(:organization)
    post :create, :user_id => subject.current_user.object_key, :user_organization_filter => attributes_for(:user_organization_filter, :organization_ids => "#{test_org.id}")

    expect(UserOrganizationFilter.count).to eq(1)
    test_filter = UserOrganizationFilter.first
    expect(assigns(:user_organization_filter)).to eq(test_filter)
    expect(test_filter.organizations).to include(test_org)
    expect(test_filter.user).to eq(subject.current_user)
  end
  it 'PUT update' do
    test_org = create(:organization)
    put :update, :user_id => subject.current_user.object_key, :id => test_filter.object_key, :user_organization_filter => {:description => 'new descrip222', :organization_ids => "#{test_org.id}"}
    test_filter.reload

    expect(assigns(:user_organization_filter)).to eq(test_filter)
    expect(test_filter.description).to eq('new descrip222')
    expect(test_filter.organizations).to include(test_org)
  end

  it 'DELETE destroy' do
    delete :destroy, :user_id => subject.current_user.object_key, :id => test_filter.object_key

    expect(UserOrganizationFilter.find_by(:object_key => test_filter.object_key)).to be nil
  end
end
