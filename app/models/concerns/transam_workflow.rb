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

  # Returns a collection of classes that implement TransamWorkflow
  def self.implementors
    ObjectSpace.each_object(Class).select { |klass| klass < TransamWorkflow }
  end


  module ClassMethods

    def transam_workflow_transitions
      []
      # array of hashes in this format
      # {event_name: event_name, from_state: from, to_state: to, guard: method_name, can: method_name, icon: font-awesome-icon-name, label: title, before: method_name, after: method_name}
    end

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

    # Returns the list of states that can transition to a target state
    def state_predecessors state
      a = []
      self.new.state_paths(:to => state.to_s).each do |state|
        a << state.last.from_name.to_s
      end
      a.uniq
    end

    # Returns the list of states that can precurse an event
    def event_predecessors event
      a = []
      # state machine provides a set of can_xxxxx? properties to test if an event
      # can be fired for an object instance in a specific state. Here xxxxx is
      # the event name. Because we don't have the ability to know what events
      # are present or required to be checked we need to use reflection to
      # query the state machine

      # Set up the event we want to test
      target_method = "can_#{event.to_s}?".to_sym
      # Iterate over every state to see if the event can be fired
      obj = self.new
      state_names.each do |s|
        # Set the state to test
        obj.state = s
        # Test it
        method_object = obj.method(target_method)
        if method_object.call
          # positive response to keep this state
          a << s
        end
      end
      a.uniq
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


  # ======================= state_machine setup =======================

  # Make sure the machine gets initialized so the initial state gets set properly
  def initialize(*)
    super
    machine
  end

  # Create a state machine for this instance dynamically based on the
  # transitions defined from the source above
  def machine
    unless self.class.transam_workflow_transitions.empty?
      @machine ||= Machine.new(self, initial: self.class.transam_workflow_transitions.first[:from_state]) do

        self.class.transam_workflow_transitions.each do |attrs|
          if attrs[:event_name].present? && attrs[:from_state].present? && attrs[:to_state].present?
            transition_attrs = {attrs[:from_state] => attrs[:to_state], on: attrs[:event_name]}
            transition_attrs[:if] = attrs[:guard] if attrs[:guard].present?
            transition(transition_attrs)

            before_transition on: attrs[:event_name], do: attrs[:before] unless attrs[:before].blank?
            after_transition on: attrs[:event_name], do: attrs[:after] unless attrs[:after].blank?
          end
        end
      end
    end
  end

end
