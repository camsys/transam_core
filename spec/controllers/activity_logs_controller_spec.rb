require 'rails_helper'

RSpec.describe ActivityLogsController, :type => :controller do

  let(:test_user) { create(:admin) }

  before(:each) do
    test_user.organizations << test_user.organization
    test_user.viewable_organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  it "GET index" do
    test_activity = create(:activity_log, :organization => test_user.organization, :user => test_user)
    get :index

    expect(assigns(:activities)).to include(test_activity)
  end
  it "GET show" do
    test_activity = create(:activity_log, :organization => test_user.organization, :user => test_user)
    params = {id: test_activity}
    get :show, params: params

    expect(assigns(:activity)).to eq(test_activity)
  end

end
