class Task < ActiveRecord::Base
  
  # Include the object key mixin
  include TransamObjectKey
  
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults
  
  # Associations
  belongs_to :from_organization, :class_name => "Organization", :foreign_key => "from_organization_id"  
  belongs_to :for_organization, :class_name => "Organization", :foreign_key => "for_organization_id"  
  belongs_to :from_user, :class_name => "User", :foreign_key => "from_user_id"  
  belongs_to :assigned_to, :class_name => "User", :foreign_key => "assigned_to_user_id"  
  belongs_to :priority_type
  
  belongs_to :agency
  belongs_to :user
  belongs_to :to_user
  belongs_to :priority_type
  belongs_to :task_status_type
  
  # Each task can have notes associated with it. Comments are destroyed when the task is destroyed
  has_many    :comments,  :as => :commentable, :dependent => :destroy
    
  # Validations on core attributes
  validates :from_user_id,          :presence => true
  validates :from_organization_id,  :presence => true
  validates :priority_type_id,      :presence => true
  validates :assigned_to_user_id,   :presence => true
  validates :for_organization_id,   :presence => true
  validates :subject,               :presence => true
  validates :body,                  :presence => true
  validates :complete_by,           :presence => true
   
  default_scope { order('complete_by') }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :from_user_id,
    :from_organization_id, 
    :priority_type_id, 
    :tastk_sttaus_type_id,
    :assigned_to_user_id, 
    :for_organization_id,
    :subject,
    :body,
    :send_reminder,
    :complete_by
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
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def name
    subject
  end
  
  def cancelled?
    (task_status_type_id == 5)
  end
  def complete?
    (task_status_type_id == 3)
  end
  def on_hold?
    (task_status_type_id == 4)
  end
  def in_progress?
    (task_status_type_id == 2)
  end
  def not_started?
    (task_status_type_id == 1)
  end
  
  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
        
  # Set resonable defaults for a new asset
  def set_defaults
    self.task_status_type_id ||= TaskStatusType.find_by_name('Not Started').id    
    self.send_reminder ||= true   
    self.complete_by ||= Date.today + 1.day
  end    
      
end
