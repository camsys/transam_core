require 'rails_helper'

RSpec.describe TransamWorkflow do

  let(:test_car) { Car.new }

  it '.event_names' do
    expect(Car.event_names).to eq(['first_gear', 'idle'])
  end
  it '.state_names' do
    expect(Car.state_names).to eq(['parked', 'first', 'second', 'third', 'fourth', 'fifth', 'neutral'])
  end
  it '.event_transitions' do
    transitions = Car.event_transitions
    expect(transitions).to include({'parked' => 'first'})
    expect(transitions).to include({'first' => 'neutral'})
    expect(transitions).to include({'second' => 'neutral'})
    expect(transitions).to include({'third' => 'neutral'})
    expect(transitions).to include({'fourth' => 'neutral'})
    expect(transitions).to include({'fifth' => 'neutral'})
    expect(transitions).to include({'parked' => 'neutral'})
  end

  it '.state_predecessors' do
    expect(Car.state_predecessors('neutral')).to eq(['parked', 'first', 'second', 'third', 'fourth', 'fifth'])
  end

  it '.event_predecessors' do
    expect(Car.event_predecessors('idle')).to eq(['parked', 'first', 'second', 'third', 'fourth', 'fifth'])
  end

  it '.allowable_events' do
    expect(test_car.allowable_events).to eq(['first_gear', 'idle'])

    test_car.state = 'first'
    expect(test_car.allowable_events).to eq(['idle'])
  end

end
