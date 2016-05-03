#------------------------------------------------------------------------------
#
# AssetDispositionUpdateJob
#
# Records that an asset has been disposed.
#
#------------------------------------------------------------------------------
class AssetDispositionUpdateJob < AbstractAssetUpdateJob
  
  
  def execute_job(asset)
    asset_event_type = AssetEventType.where(:class_name => 'DispositionUpdateEvent').first
    asset_event = AssetEvent.where(:asset_id => asset.id, :asset_event_type_id => asset_event_type.id).last
    if(asset_event.disposition_type_id == 2)
      asset.transfer asset_event.organization_id
    end

    asset.record_disposition
  end

  def prepare
    Rails.logger.debug "Executing AssetDispositionUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end