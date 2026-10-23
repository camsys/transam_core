require "rails_helper"

# TTPLAT-3118: routes that TTPLAT-3091 narrows around but must keep. Each form
# or Ajax caller named below posts to or reads from one of these.
RSpec.describe "Surviving routes", type: :routing do

  describe 'nested create under inventory' do
    # asset forms post to inventory_comments_path etc.
    it 'routes POST /inventory/:inventory_id/comments to comments#create' do
      expect(:post => '/inventory/abc/comments').to route_to('comments#create', :inventory_id => 'abc')
    end

    it 'routes POST /inventory/:inventory_id/documents to documents#create' do
      expect(:post => '/inventory/abc/documents').to route_to('documents#create', :inventory_id => 'abc')
    end

    it 'routes POST /inventory/:inventory_id/images to images#create' do
      expect(:post => '/inventory/abc/images').to route_to('images#create', :inventory_id => 'abc')
    end
  end

  describe 'task comments' do
    # tasks/_comments.html.haml posts to task_comments_path
    it 'routes POST /tasks/:task_id/comments to comments#create' do
      expect(:post => '/tasks/abc/comments').to route_to('comments#create', :task_id => 'abc')
    end
  end

  describe 'images' do
    # shared/_images.html.haml reads the Photos table from images_path(..., format: :json)
    it 'routes GET /images to images#index' do
      expect(:get => '/images').to route_to('images#index')
    end

    it 'routes GET /images.json to images#index as json' do
      expect(:get => '/images.json').to route_to('images#index', :format => 'json')
    end

    it 'routes GET /images/:id/download to images#download' do
      expect(:get => '/images/abc/download').to route_to('images#download', :id => 'abc')
    end
  end

  describe 'query filters' do
    it 'routes GET /query_filters/manufacturers to query_filters#manufacturers' do
      expect(:get => '/query_filters/manufacturers').to route_to('query_filters#manufacturers')
    end
  end

  describe 'asset_path helper' do
    # Two blocks in config/routes.rb map /inventory/:id (resources :inventory, and
    # resources :assets, path: :inventory), so this asserts only that the helper
    # exists and builds the inventory URL, not which block answers a request.
    it 'resolves asset_path to /inventory/:id' do
      expect(Rails.application.routes.url_helpers.asset_path('abc')).to eq('/inventory/abc')
    end
  end

end
