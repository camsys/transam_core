require "rails_helper"

# TTPLAT-3091 instance 1: the manufacturers index was removed with its controller.
# Ask the router directly, not the controller.
RSpec.describe "Removed routes", type: :routing do

  it 'no longer routes GET /manufacturers' do
    expect(:get => '/manufacturers').not_to be_routable
  end
end
