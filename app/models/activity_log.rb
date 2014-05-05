class ActivityLog
  validates :organization_id, :item_type, :item_id, :user_id, :updated_by, :activity, :activity_time, :presence => true
end