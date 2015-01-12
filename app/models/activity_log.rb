class ActivityLog < ActiveRecord::Base
    
  validates :organization_id, :item_type, :user_id, :activity, :activity_time, :presence => true
  
  belongs_to :organization
  belongs_to :user

  SEARCHABLE_FIELDS = [
    'object_key',
    'activity',
    'organization_name'
  ]

  def organization_name
  	organization.name
  end
  
end

