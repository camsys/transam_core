class UserNotification < ActiveRecord::Base

  # Associations
  belongs_to :user, -> { unscope(where: :active) }
  belongs_to :notification

  scope :unopened, -> { joins('INNER JOIN notifications ON notification_id = notifications.id').where('opened_at IS NULL AND notifications.active = true') }
  scope :opened, -> { where('opened_at IS NOT NULL') }

end
