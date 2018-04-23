require 'rails_helper'

RSpec.describe IssuesController, :type => :controller do

  let(:test_user) { create(:admin) }
  let(:test_issue) { create(:issue) }

  before(:each) do
    Organization.destroy_all
    test_user.organizations << test_user.organization
    test_user.viewable_organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  # it 'GET index' do
  #   test_issue.save!
  #   get :index
  #
  #   expect(assigns(:issues)).to include(test_issue)
  # end
  #
  # it 'GET show' do
  #   get :show, :id => test_issue.object_key
  #
  #   expect(assigns(:issue)).to eg(test_issue)
  # end

  it 'GET success' do
    get :success, :id => test_issue.object_key

    expect(assigns(:issue)).to eq(test_issue)
  end

  it 'GET new' do
    get :new

    expect(assigns(:issue).to_json).to eq(Issue.new.to_json)
  end

  # it 'GET edit' do
  #   get :edit, :id => test_issue.object_key
  #
  #   expect(assigns(:issue)).to eq(test_issue)
  # end

  it 'POST create' do
    Issue.destroy_all
    post :create, {:issue => attributes_for(:issue)}

    expect(assigns(:issue).creator).to eq(subject.current_user)
    expect(Issue.count).to eq(1)
  end

  # it 'POST update' do
  #   post :update, {:id => test_issue.object_key, :issue => {:comments => 'Test Comment2'}}
  #   test_comment.reload
  #
  #   expect(test_issue.comments).to eq('Test Comment2')
  # end
  #
  # it 'DELETE destroy' do
  #   delete :destroy, {:id => test_issue.object_key}
  #
  #   expect(Issue.find_by(:object_key => test_issue.object_key)).to be nil
  # end

end
