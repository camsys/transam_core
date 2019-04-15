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

      object.class.transam_workflow_transitions.map{|attrs| attrs[:before] if attrs[:before].present?}.compact.each do |before_transition|
        define_method(before_transition) { object.send(before_transition) }
      end
      object.class.transam_workflow_transitions.map{|attrs| attrs[:after] if attrs[:after].present?}.compact.each do |after_transition|
        define_method(after_transition) { object.send(after_transition) }
      end
    end

    machine_class.new
  end
end