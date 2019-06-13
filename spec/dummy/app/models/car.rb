class Car < ApplicationRecord

  include TransamWorkflow


  def self.transam_workflow_transitions
    [
        {event_name: 'first_gear', from_state: 'parked', to_state: 'first'},
        {event_name: 'idle', from_state: ['parked','first', 'second', 'third', 'fourth','fifth'], to_state: 'neutral'}
    ]
  end
end
