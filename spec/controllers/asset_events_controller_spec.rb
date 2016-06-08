require 'rails_helper'

RSpec.describe AssetEventsController, :type => :controller do

  let(:test_user) { create(:admin) }
  let(:bus) { create(:buslike_asset, :organization => subject.current_user.organization) }
  let(:test_event) { create(:asset_event) }

  before(:each) do
    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  describe 'GET index' do
    it 'all events of an asset' do
      bus.asset_events << test_event
      bus.save!
      get :index, :inventory_id => bus.object_key

      expect(assigns(:filter_type)).to eq(0)
      expect(assigns(:page_title)).to eq("#{bus.name}: History")
      expect(assigns(:events)).to include(test_event)
    end
    it 'events of one type' do
      bus.asset_events << test_event
      test_event2 = create(:asset_event, :asset_event_type_id => 2)
      bus.asset_events << test_event2
      bus.save!
      get :index, :inventory_id => bus.object_key, :filter_type => test_event.asset_event_type.id

      expect(assigns(:filter_type)).to eq(test_event.asset_event_type.id)
      expect(assigns(:page_title)).to eq("#{bus.name}: History")
      expect(assigns(:events)).to include(test_event)
      expect(assigns(:events)).not_to include(test_event2)
    end
  end
  it 'GET new' do
    get :new, :inventory_id => bus.object_key, :event_type => 1

    expect(assigns(:asset)).to eq(Asset.get_typed_asset(bus))
    expect(assigns(:asset_event).to_json).to eq(ConditionUpdateEvent.new(:asset_event_type_id => 1, :asset_id => bus.id).to_json)
  end
  it 'GET show' do
    bus.asset_events << test_event
    bus.save!
    get :show, :inventory_id => bus.object_key, :id => test_event.object_key

    expect(assigns(:asset)).to eq(Asset.get_typed_asset(bus))
    expect(assigns(:asset_event)).to eq(AssetEvent.as_typed_event(test_event))
  end
  it 'GET edit' do
    bus.asset_events << test_event
    bus.save!
    get :edit, :inventory_id => bus.object_key, :id => test_event.object_key

    expect(assigns(:asset)).to eq(Asset.get_typed_asset(bus))
    expect(assigns(:asset_event)).to eq(AssetEvent.as_typed_event(test_event))
  end
  it 'POST update' do
    bus.asset_events << test_event
    bus.save!
    post :update, :inventory_id => bus.object_key, :id => test_event.object_key, :asset_event => {:comments => 'test comments2', :event_date => Date.today.strftime('%m/%d/%Y')}
    test_event.reload

    expect(test_event.comments).to eq('test comments2')
  end
  it 'POST create' do
    post :create, :inventory_id => bus.object_key, :event_type => 1, :asset_event => {:event_date => Date.today.strftime('%m/%d/%Y')}
    bus.reload

    expect(bus.asset_events.count).to eq(1)
  end
  it 'DELETE destroy' do
    bus.asset_events << test_event
    bus.save!
    delete :destroy, :inventory_id => bus.object_key, :id => test_event.object_key

    expect(AssetEvent.find_by(:object_key => test_event.object_key)).to be nil
  end

  describe "workflow events" do
    let(:early_disp_event) { create(:early_disposition_request_update_event) }

    before(:each) do 
      request.env["HTTP_REFERER"] = root_path
    end

    it 'fire workflow event' do
      expect{
        get :fire_workflow_event, :inventory_id => bus.object_key, :id => early_disp_event.object_key, :event => 'approve'
        }.to change {WorkflowEvent.count}.by(1)
    end

    it 'refresh current page' do 
      get :fire_workflow_event, :inventory_id => bus.object_key, :id => early_disp_event.object_key, :event => 'approve'

      expect(response).to redirect_to(root_path)
    end

    it 'redirect to final disposition page if an early disposition event was approved via transfer ' do 
      bus.asset_events << early_disp_event
      bus.save!

      get :fire_workflow_event, :inventory_id => bus.object_key, :id => early_disp_event.object_key, :event => 'approve_via_transfer'

      expect(response).to redirect_to(new_inventory_asset_event_path(bus, :causal_asset_event => bus.asset_events.last.object_key, :causal_asset_event_name => 'approve_via_transfer', :event_type => DispositionUpdateEvent.asset_event_type.id,  :transferred => '1'))
    end

  end
end
