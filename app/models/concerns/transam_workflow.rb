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

      (transam_workflow_transitions.empty? ? state_machine : self.new.machine.definition).events.each do |e|
        a << e.name.to_s
      end
      a
    end
    # Returns the list of allowable states for this class
    def state_names()
      a = []
      (transam_workflow_transitions.empty? ? state_machine : self.new.machine.definition).states.each do |s|
        a << s.name.to_s
      end
      a
    end

    def event_transitions(event=nil)
      a = []

      evts = (transam_workflow_transitions.empty? ? state_machine : self.new.machine.definition).events
      evts = evts.select{|x| x.name.to_s == event.to_s} unless event.nil?
      evts.each do |evt|
        evt.branches.each do |branch|
          branch.state_requirements.each do |state_req|
            state_req[:from].values.each do |from|
              a << {from => state_req[:to].values[0]}
            end
          end
        end
      end

      a.uniq
    end

    # Returns the list of states that can transition to a target state
    def state_predecessors state
      a = []
      event_transitions.each do |transition|
        a << transition.keys.first if transition.values.first.to_s == state.to_s
      end

      a.uniq
    end

    # Returns the list of states that can precurse an event
    def event_predecessors event
      a = []

      evt = (transam_workflow_transitions.empty? ? state_machine : self.new.machine.definition).events.find{|x|x.name == event.to_s}

      evt.branches.each do |branch|
        a << branch.state_requirements.map{ |state_req| state_req[:from].values}
      end

      a.flatten.uniq
    end

  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Get the allowable events for this state as strings (for use in views)
  def allowable_events()
    (self.class.transam_workflow_transitions.empty? ? self : self.machine).state_events.map{|x| x.to_s}
  end

  def allowable_event_objects
    machine_obj = (self.class.transam_workflow_transitions.empty? ? self : self.machine)
    machine_obj.class.state_machine.events.select{|x| machine_obj.state_events.include? x.name}
  end

  # Simple override of the workflow events. Always use this method as it can be
  # filtered to limit viewable events
  def history()
    workflow_events
  end

  # Returns the correct icon for a workflow event
  def get_workflow_event_icon(event_name)

    custom_icon = self.class.transam_workflow_transitions.detect{|t| t[:event_name].to_s == event_name.to_s}.try(:[], :icon)
    if custom_icon
      custom_icon
    elsif event_name == 'retract'
      'fa-eject'
    elsif event_name == 'transmit' || event_name == 'submit'
      'fa-share'
    elsif event_name == 'accept' || event_name == 'authorize'
      'fa-check-square-o'
    elsif event_name == 'start' || event_name == 'publish'
      'fa-play'
    elsif event_name == 'complete' || event_name == 'close'
      'fa-check-square'
    elsif event_name == 'cancel'
      'fa-stop'
    elsif event_name == 'not_authorize'
      'fa-ban'
    elsif event_name == 're_start'
      'fa-play'
    elsif event_name == 'halt'
      'fa-pause'
    elsif event_name == 'retract' || event_name == 'reopen'
      'fa-reply'
    elsif event_name == 'return' || event_name == 'reject' || event_name == 'unapprove'
      'fa-chevron-circle-left'
    elsif event_name == 'approve'
      'fa-plus-square'
    elsif event_name == 'approve_via_transfer'
      'fa-chevron-circle-right'
    else
      ''
    end
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
    workflow_instance = self
    unless workflow_instance.class.transam_workflow_transitions.empty?
      @machine ||= Machine.new(workflow_instance, initial: (workflow_instance.read_attribute(:state) || workflow_instance.class.transam_workflow_transitions.first[:from_state]), action: :save) do

        workflow_instance.class.transam_workflow_transitions.each do |attrs|
          if attrs[:event_name].present? && attrs[:from_state].present? && attrs[:to_state].present?
            transition_attrs = {attrs[:from_state] => attrs[:to_state]}
            event_attrs = attrs[:human_name] ? {human_name: attrs[:human_name]} : {}
            if attrs[:guard].present?
              if attrs[:guard].is_a?(Hash)
                transition_attrs[:if] = Proc.new { attrs[:guard].map{|k,v| workflow_instance.state.to_s == k.to_s && workflow_instance.send(v)}.any? }
              else
                transition_attrs[:if] = Proc.new { workflow_instance.send(attrs[:guard]) }
              end
            end

            state(attrs[:from_state], {human_name: attrs[:from_state_human_name]}) if attrs[:from_state_human_name].present?
            state(attrs[:to_state], {human_name: attrs[:to_state_human_name]}) if attrs[:to_state_human_name].present?

            event(attrs[:event_name], event_attrs) { branches << transition(transition_attrs) }
          end
        end

        before_transition do |this_machine, this_transition|
          this_machine.machine_before_transition(this_transition)
        end
        after_transition do |this_machine, this_transition|
          this_machine.machine_after_transition(this_transition)
        end
      end
    end
  end

end
