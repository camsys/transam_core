class ActivityLog < ActiveRecord::Base

  validates :organization_id, :item_type, :user_id, :activity, :activity_time, :presence => true

  belongs_to :organization
  belongs_to :user, -> { unscope(where: :active) }

  def to_s
    item_type
  end
  
end
