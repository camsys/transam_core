class MessageTemplate < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Associations
  belongs_to :priority_type

  # Validations on core attributes
  validates :priority_type_id,  :presence => true
  validates :name,              :presence => true
  validates :subject,           :presence => true
  validates :delivery_rules,              :presence => true
  validates :body,              :presence => true

  scope :active, -> { where(active: true) }

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :priority_type_id,
    :name,
    :description,
    :subject,
    :body,
    :delivery_rules,
    :active,
    :email_enabled
  ]

  def self.allowable_params
    FORM_PARAMS
  end

  # Set resonable defaults
  def set_defaults
    self.active = true if self.active.nil?
    self.priority_type_id = PriorityType.default&.id if self.priority_type_id.nil?
    self.email_enabled = false if self.email_enabled.nil?
  end

end
