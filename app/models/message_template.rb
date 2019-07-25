class MessageTemplate < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults
  after_create      :notify_template_changes
  after_save        :template_changed

  # Associations
  belongs_to :priority_type

  # Validations on core attributes
  validates :priority_type_id,  :presence => true
  validates :name,              :presence => true
  validates :subject,           :presence => true
  validates :delivery_rules,              :presence => true
  validates :body,              :presence => true

  validate :validate_message_or_email_enabled

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

  protected

  # Set resonable defaults
  def set_defaults
    self.active = false if self.active.nil?
    self.priority_type_id = PriorityType.default&.id if self.priority_type_id.nil?
    self.message_enabled = true if self.message_enabled.nil?
    self.email_enabled = true if self.email_enabled.nil?
    self.is_system_template = false if self.is_system_template.nil?
    self.is_implemented = false if self.is_implemented.nil?
  end

  def validate_message_or_email_enabled
    message_enabled || email_enabled
  end

  def notify_template_changes


    Delayed::Job.enqueue MessageTemplateInformerJob.new(object_key)
  end

  def template_changed
    if delivery_rules_changed? || body_changed?
      update!(is_implemented: false)
      notify_template_changes
    end
  end

end
