require 'rails_helper'

RSpec.describe TasksController, :type => :controller do

  let(:test_user) { create(:admin) }
  let(:test_task) { create(:task) }

  before(:each) do
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  # it 'GET filter' do
  #   test_task.update!(:complete_by => Date.today)
  #   get :filter, :select => '1', :start => (Date.today - 1.day).strftime('%Y-%m-%d'), :end => (Date.today+1.day).strftime('%Y-%m-%d')
  #
  #   expect(JSON.parse(response.body)).to include(test_task.object_key)
  # end
  it 'POST fire_workflow_event' do
    request.env["HTTP_REFERER"] = root_path
    post :fire_workflow_event, :id => test_task.object_key, :event => 'start'
    test_task.reload

    expect(test_task.state).to eq('started')
  end
  it 'POST change_owner' do
    request.env["HTTP_REFERER"] = root_path
    new_user = create(:normal_user)
    post :change_owner, :id => test_task.object_key, :user => new_user.object_key
    test_task.reload
    expect(assigns(:task)).to eq(test_task)
    expect(test_task.assigned_to_user).to eq(new_user)
  end
  it 'GET index' do
    test_task.update!(:state => 'started', :organization => subject.current_user.organization)
    completed_task = create(:task, :state => 'completed', :organization => subject.current_user.organization)
    get :index

    expect(assigns(:open_tasks).map{|t| t.object_key}).to include(test_task.object_key)
    expect(assigns(:closed_tasks).map{|t| t.object_key}).to include(completed_task.object_key)
  end
  it 'GET show' do
    get :show, :id => test_task.object_key

    expect(assigns(:task)).to eq(test_task)
  end
  it 'GET new' do
    get :new

    expect(assigns(:task).to_json).to eq(Task.new(:user => subject.current_user, :priority_type => PriorityType.default).to_json)
  end
  it 'GET edit' do
    test_task.update!(:taskable_id => subject.current_user.id, :user_id => subject.current_user.id)
    get :edit, :user_id => subject.current_user.object_key, :id => test_task.object_key

    expect(assigns(:taskable)).to eq(subject.current_user)
    expect(assigns(:task)).to eq(test_task)
  end
  it 'POST create' do
    request.env["HTTP_REFERER"] = tasks_path
    post :create, :user_id => subject.current_user.object_key, :task => attributes_for(:task, :user => nil, :organization => nil)

    expect(assigns(:taskable)).to eq(subject.current_user)
    expect(assigns(:task).organization).to eq(subject.current_user.organization)
    expect(assigns(:task).user).to eq(subject.current_user)
    expect(subject.current_user.tasks.count).to eq(1)
  end
  it 'POST update' do
    test_task.update!(:taskable => subject.current_user)
    post :update, :user_id => subject.current_user.object_key, :id => test_task.object_key, :task => {:subject => 'Test Task Subject2'}
    test_task.reload

    expect(assigns(:taskable)).to eq(subject.current_user)
    expect(assigns(:task)).to eq(test_task)
    expect(test_task.subject).to eq('Test Task Subject2')
  end
end
