class Issue < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey
      
  # Callbacks
  after_initialize  :set_defaults
            
  # Each issue was created by a user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by_id"

  # Each issue has a type [Bug Suggestion, etc.]
  belongs_to :issue_type

  # Each issue has a web browser type [IE 8, IE 9, IE 10, Chrome, Firefox]
  belongs_to :web_browser_type

  # Each issue has a status [Open, Resolved] this list could grow to include under investigation or rejected which is why it isn't a boolean
  belongs_to :issue_type

  validates :issue_type_id,                   :presence => true
  validates :web_browser_type_id,             :presence => true
  validates :comments,                        :presence => true
  validates :created_by_id,                   :presence => true
  validates :resolution_comments,             :presence => true, :if => "issue_status == 'Resolved?"
  # validates_presence_of :resolution_comments, :if :issue_status == 'Resolved'

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :issue_type_id,
    :web_browser_type_id,
    :comments,
    :issue_status,
    :resolution_comments
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
    
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new asset event
  def set_defaults

  end    
    
  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
  
end
