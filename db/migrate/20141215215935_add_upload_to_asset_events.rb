20141215112140
class AddUploadToAssetEvents < ActiveRecord::Migration
  def change
    add_reference :asset_events, :upload, :after => :asset_event_type_id
    add_index     :asset_events, :upload_id, :name => :asset_events_idx5
  end
end
