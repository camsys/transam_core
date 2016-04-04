# Early disposition request event. 
# Used to request to early dispose an asset 
#

# Include the FileSizevalidator mixin
require 'file_size_validator'

class EarlyDispositionRequestUpdateEvent < AssetEvent

  # Include the Workflow module
  include TransamWorkflow

  # From system config. This is the maximum document size that can be uploaded
  MAX_UPLOAD_FILE_SIZE = Rails.application.config.max_upload_file_size

  # Use the carrierway uploader
  mount_uploader :document,   DocumentUploader

  # Callbacks
  after_initialize :set_defaults

  # Validations
  validates :comments,            :presence => true
  validates :document,            :presence => true, :file_size => { :maximum => MAX_UPLOAD_FILE_SIZE.megabytes.to_i }

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
  # tasks which are currently active based on the workflow
  scope :active, -> { where("state == 'new' ") }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :state,
    :document
  ]

   #------------------------------------------------------------------------------
  #
  # State Machine
  #
  # Used to track the state of an early dispostion request event 
  #
  #------------------------------------------------------------------------------
  state_machine :state, :initial => :new do

    #-------------------------------
    # List of allowable states
    #-------------------------------

    # initial state. All are created in this state
    state :new

    # request is approved
    state :approved

    # request is rejected
    state :rejected

    # request is conditionally approved, only allow transfering the asset to another agency
    state :transfer_approved

    #---------------------------------------------------------------------------
    # List of allowable events. Events transition a request event from one state to another
    #---------------------------------------------------------------------------

    # approve a request
    event :approve do
      transition :new => :approved
    end

    # reject a request
    event :reject do
      transition :new => :rejected
    end

    # conditionally approve a request by only allowing asset transfer to another agency
    event :approve_via_transfer do
      transition :new => :transfer_approved
    end

    # Callbacks
    before_transition do |request, transition|
      Rails.logger.debug "Transitioning early dispositin request #{request.object_key} from #{transition.from_name} to #{transition.to_name} using #{transition.event}"
    end
  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #returns the asset event type for this type of event
  def self.asset_event_type
    AssetEventType.find_by_class_name(self.name)
  end

  # when state changes, notify related users
  def self.workflow_notification_enabled?
    true
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def get_update
    "Early disposition request was made"
  end

  def get_latest_update
    state_desc = case state.to_s
    when 'new'
      "made"
    when 'transfer_approved'
      "approved via transfer"
    else
      state
    end

    "Early disposition request was #{state_desc}"
  end

  def is_new?
    state == "new"
  end

  def is_unconditional_approved?
    state == "approved"
  end

  def is_approved?
    is_unconditional_approved? || state == "transfer_approved"
  end

  def is_rejected?
    state == "rejected"
  end

  # default recipients
  # if :notification_recipients is defined, then :notification_recipients takes precedence 
  def default_notification_recipients(event)
    recipients = case event.try(:to_sym)
    when :new
      # notify managers
      Role.find_by_name(:manager).try(:users)

    when :reject, :approve_via_transfer, :approve
      # notify managers and creator
      (Role.find_by_name(:manager).try(:users) || []) + [creator]
    end

    recipients || []
  end

  def event_in_passive_tense(event)
    case event.try(:to_sym)
    when :new
      'created'
    when :reject
      'rejected'
    when :approve
      'approved'
    when :approve_via_transfer
      'approved via transfer'
    end
  end

  def notify_event_by(sender, event)
    event = event.to_sym

    event_desc = event_in_passive_tense(event)

    event_url = Rails.application.routes.url_helpers.inventory_asset_event_path self.try(:asset), self
    
    recipients = if self.respond_to?(:notification_recipients)
      notification_recipients(event)
    else
      default_notification_recipients(event)
    end
    (recipients || []).uniq.each do |to_user|
      if to_user && to_user != sender
        msg = Message.new
        msg.user          = sender
        msg.organization  = sender.try(:organization)
        msg.to_user       = to_user
        msg.subject       = "Early disposition request for #{asset.asset_tag} #{event_desc}"
        msg.body          = "Early disposition request for #{asset.name} has been #{event_desc} by #{sender}. The request can be viewed at <a href='#{event_url}'>here</a>"
        msg.priority_type = PriorityType.default
        msg.save
      end
    end
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.event_date ||= Date.today
    self.state ||= "new"
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

end
