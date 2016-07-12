class Notification < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Associations
  belongs_to  :notifiable, polymorphic: true
  has_many     :user_notifications
  has_many     :users, through: :user_notifications

  # Validations on core attributes
  validates :text,   :presence => true
  validates :link,   :presence => true

  default_scope { order('created_at DESC') }

  scope :active, -> { where(active: true) }

  protected
  def set_defaults
    self.active = self.active.nil? ? true : self.active
  end
end
