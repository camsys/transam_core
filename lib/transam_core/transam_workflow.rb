module TransamWorkflow
  extend ActiveSupport::Concern
  
  included do
    # Has 0 or more workflow events. Using a polymorphioc association.
    has_many :workflow_events, :as => :accountable, :dependent => :destroy
    
    validates :state, :presence => true
    
    #------------------------------------------------------------------------------
    #
    # State Machine 
    #
    # Generic state machine for approvals
    #
    #------------------------------------------------------------------------------  
    state_machine :state, :initial => :unsubmitted do
  
      #-------------------------------
      # List of allowable states
      #-------------------------------
      
      # initial state
      state :unsubmitted
      
      # state used to signify it has been submitted and is pending approval 
      state :pending_approval
        
      # state used to signify that the order has been approved by the program manager
      state :approved
  
      # state used to signify that the order has been returned unaproved
      state :returned
  
      #---------------------------------------------------------------------------
      # List of allowable events. Events transition a workflow from one state to another
      #---------------------------------------------------------------------------
                
      # submit for approval.
      event :submit do
        
        transition [:unsubmitted, :returned] => :pending_approval
        
      end
    
      # A program manager is returning a project for additional information or changes
      event :return do
        
        transition [:pending_approval] => :returned
        
      end    
  
      # A program manager is approving a project
      event :approve do
        
        transition [:pending_approval] => :approved
        
      end    
        
      # Callbacks
      before_transition do |obj, transition|
        Rails.logger.debug "Transitioning #{obj.to_s} from #{transition.from_name} to #{transition.to_name} using #{transition.event}"
      end       
    end
    
  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  module ClassMethods
    # Return the list of allowable event names for this class
    def event_names()
      a = []
      state_machine.events.each do |e|
        a << e.name.to_s
      end
      a    
    end
    # Returns the list of allowable states for this class
    def state_names()
      a = []
      state_machine.states.each do |s|
        a << s.name.to_s
      end
      a
    end    
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Get the allowable events for this state as strings
  def allowable_events()
    a = []
    self.state_events.each do |evt|
      a << evt.to_s
    end
    a
  end

  # Simple override of the workflow events. Always use this method as it can be 
  # filtered to limit viewable events  
  def history()
    workflow_events
  end
    
end
