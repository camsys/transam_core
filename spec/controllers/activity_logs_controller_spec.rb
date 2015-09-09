require 'rails_helper'

RSpec.describe ActivityLogsController, :type => :controller do
  include Devise::TestHelpers

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

  it "GET index" do
    test_activity = create(:activity_log, :organization => test_user.organization, :user => test_user)
    get :index

    expect(assigns(:activities)).to include(test_activity)
  end
  it "GET show" do
    test_activity = create(:activity_log, :organization => test_user.organization, :user => test_user)
    get :show, :id => test_activity

    expect(assigns(:activity)).to eq(test_activity)
  end

end
