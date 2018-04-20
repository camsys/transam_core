require 'rails_helper'

RSpec.describe CommentsController, :type => :controller do

  let(:test_user) { create(:admin) }
  let(:bus) { create(:buslike_asset) }

  before(:each) do
    test_user.organizations << test_user.organization
    test_user.viewable_organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  it 'GET index' do
    test_comment = create(:comment, :commentable_id => bus.id)
    bus.comments << test_comment
    bus.save!
    get :index, :asset_id => bus.object_key
    bus.reload

    expect(assigns(:commentable)).to eq(bus)
    expect(assigns(:comments)).to include(test_comment)
  end

  it 'GET new' do
    get :new, :inventory_id => bus.object_key

    expect(assigns(:commentable)).to eq(bus)
    expect(assigns(:comment).to_json).to eq(Comment.new.to_json)
  end

  it 'GET edit' do
    test_comment = create(:comment, :commentable_id => bus.id)
    bus.comments << test_comment
    bus.save!
    get :edit, {:inventory_id => bus.object_key, :id => test_comment.object_key}

    expect(assigns(:commentable)).to eq(bus)
    expect(assigns(:comment)).to eq(test_comment)
  end

  it 'POST create' do
    request.env["HTTP_REFERER"] = root_path
    Comment.destroy_all
    post :create, {:inventory_id => bus.object_key, :comment => attributes_for(:comment)}
    bus.reload

    expect(assigns(:commentable)).to eq(bus)
    expect(bus.comments.count).to eq(1)
  end

  it 'POST update' do
    test_comment = create(:comment, :commentable_id => bus.id)
    bus.comments << test_comment
    bus.save!
    post :update, {:inventory_id => bus.object_key, :id => test_comment.object_key, :comment => {:comment => 'Test Comment2'}}
    test_comment.reload

    expect(test_comment.comment).to eq('Test Comment2')
  end

  it 'DELETE destroy' do
    request.env["HTTP_REFERER"] = root_path
    test_comment = create(:comment, :commentable_id => bus.id)
    bus.comments << test_comment
    bus.save!
    delete :destroy, {:inventory_id => bus.object_key, :id => test_comment.object_key}

    expect(Comment.find_by(:object_key => test_comment.object_key)).to be nil
  end

end
