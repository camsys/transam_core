#------------------------------------------------------------------------------
#
# TransamAttributes
#
# Mixin that creates a list of allowable model attributes for the Transam Controllers
# This class should be overridden to add updated attribute lists based on derived
# sub classes
#
#------------------------------------------------------------------------------
module TransamAttributes

  def asset_allowable_params
    Asset.allowable_params + GeolocatableAsset.allowable_params
  end
  
  def asset_event_allowable_params
    AssetEvent.allowable_params + 
    ConditionUpdateEvent.allowable_params + 
    ServiceStatusUpdateEvent.allowable_params + 
    ScheduleRehabilitationUpdateEvent.allowable_params + 
    DispositionUpdateEvent.allowable_params
  end

  def attachment_allowable_params
    Attachment.allowable_params
  end

  def message_allowable_params
    Message.allowable_params
  end

  def organization_allowable_params
    Organization.allowable_params + TransitAgency.allowable_params
  end

  def policy_allowable_params
    Policy.allowable_params
  end

  def task_allowable_params
    Task.allowable_params
  end

  def upload_allowable_params
    Upload.allowable_params
  end

  def user_allowable_params
    User.allowable_params
  end

  def location_allowable_params
    Location.allowable_params
  end
  
end
