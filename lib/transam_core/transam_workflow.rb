module TransamWorkflow
  extend ActiveSupport::Concern
  
  included do
    # Has 0 or more workflow events. Using a polymorphioc association.
    has_many :workflow_events, :as => :accountable, :dependent => :destroy
    
    validates :state, :presence => true
    
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
