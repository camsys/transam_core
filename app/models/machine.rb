# https://github.com/state-machines/state_machines#static--dynamic-definitions
# Generic class for building state_machines
class Machine
  def self.new(object, *args, &block)
    machine_class = Class.new
    machine = machine_class.state_machine(*args, &block)
    attribute = machine.attribute
    action = machine.action

    # Delegate attributes
    machine_class.class_eval do
      define_method(:definition) { machine }
      define_method(attribute) { object.send(attribute) }
      define_method("#{attribute}=") {|value| object.send("#{attribute}=", value) }
      define_method(action) { object.send(action) } if action

      define_method(:machine_before_transition) do |callback|
        transam_transition = object.class.transam_workflow_transitions.find{|t| t[:event_name] == callback}
        object.send(transam_transition[:before]) if transam_transition[:before]
      end
      define_method(:machine_after_transition) do |callback|
        transam_transition = object.class.transam_workflow_transitions.find{|t| t[:event_name] == callback}
        object.send(transam_transition[:after]) if transam_transition[:after]
      end
    end

    machine_class.new
  end
end