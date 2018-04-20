require 'rails_helper'

RSpec.describe NoticesController, :type => :controller do

  let(:test_user) { create(:admin) }
  let(:test_notice) { create(:notice) }

  before(:each) do
    test_user.organizations << test_user.organization
    test_user.viewable_organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  describe "GET index" do
    it 'admin' do
      test_notice.update!(:display_datetime => DateTime.current - 2.days, :end_datetime => DateTime.current - 1.days)
      get :index

      expect(assigns(:notices)).to include(test_notice)
    end
    it 'all users' do
      sign_out test_user
      sign_in create(:normal_user)
      test_notice.update!(:display_date => Date.today - 3.days, :end_date => Date.today - 2.days)
      get :index

      expect(assigns(:notices)).not_to include(test_notice)

      test_notice.update!(:end_date => Date.today + 1.days)
      get :index
      expect(assigns(:notices)).to include(test_notice)
    end
  end

  it 'GET show' do
    test_notice1 = create(:notice)
    test_notice2 = create(:notice)
    test_notice3 = create(:notice)
    get :show, :id => test_notice2.object_key
    # expect(assigns(:prev_record_key)).to eq(test_notice1.object_key)
    expect(assigns(:notice)).to eq(test_notice2)
    # expect(assigns(:next_record_key)).to eq(test_notice3.object_key)
  end

  it 'GET new' do
    get :new

    expect(assigns(:notice).to_json).to eq(Notice.new.to_json)
  end

  it 'POST reactivate' do
    test_notice.update!(:active => false)
    post :reactivate, :id => test_notice.object_key
    test_notice.reload

    expect(test_notice.active).to be true
  end

  it 'GET edit' do
    get :edit, :id => test_notice.object_key

    expect(assigns(:notice)).to eq(test_notice)
  end
  it 'POST create' do
    test_notice_type = create(:notice_type)
    post :create, {:notice => attributes_for(:notice, :notice_type_id => test_notice_type.id, :details => 'rspec details')}

    expect(Notice.last.details).to eq('rspec details')
  end
  it 'POST update' do
    post :update, {:id => test_notice.object_key, :notice => {:details => 'Test Details2'}}
    test_notice.reload

    expect(test_notice.details).to eq('Test Details2')
  end
  it 'POST deactivate' do
    request.env["HTTP_REFERER"] = root_path
    post :deactivate, :id => test_notice.object_key
    test_notice.reload

    expect(test_notice.active).to be false
  end
  it 'DELETE destroy' do
    delete :destroy, {:id => test_notice.object_key}

    expect(Notice.find_by(:object_key => test_notice.object_key)).to be nil
  end

end
