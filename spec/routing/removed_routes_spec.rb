require "rails_helper"

# TTPLAT-3091 instance 1: the manufacturers index was removed with its controller.
# Ask the router directly, not the controller.
RSpec.describe "Removed routes", type: :routing do

  it 'no longer routes GET /manufacturers' do
    expect(:get => '/manufacturers').not_to be_routable
  end

  # TTPLAT-3091 instance 2: the policy runner and its update_assets action.
  it 'no longer routes GET /policies/:id/runner' do
    expect(:get => '/policies/abc/runner').not_to be_routable
  end

  it 'no longer routes POST /policies/:id/update_assets' do
    expect(:post => '/policies/abc/update_assets').not_to be_routable
  end

  # TTPLAT-3091 instance 10: the policy distribute feature (inherit page and distribute action).
  it 'no longer routes GET /policies/:id/inherit' do
    expect(:get => '/policies/abc/inherit').not_to be_routable
  end

  it 'no longer routes POST /policies/:id/distribute' do
    expect(:post => '/policies/abc/distribute').not_to be_routable
  end

  # TTPLAT-3091 instance 3: index (and show) of comments, documents and images under the
  # legacy asset alias, and of comments under tasks. The create/update/edit/new/destroy
  # routes survive; see surviving_routes_spec.
  %w(comments documents images).each do |resource|
    it "no longer routes GET /inventory/:asset_id/#{resource}" do
      expect(:get => "/inventory/abc/#{resource}").not_to be_routable
    end

    it "no longer routes GET /inventory/:asset_id/#{resource}/:id" do
      expect(:get => "/inventory/abc/#{resource}/def").not_to be_routable
    end
  end

  it 'no longer routes GET /tasks/:task_id/comments' do
    expect(:get => '/tasks/abc/comments').not_to be_routable
  end

  it 'no longer routes GET /tasks/:task_id/comments/:id' do
    expect(:get => '/tasks/abc/comments/def').not_to be_routable
  end
end
