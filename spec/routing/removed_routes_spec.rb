require "rails_helper"

# TTPLAT-3091 instance 1: the manufacturers index was removed with its controller.
# Ask the router directly, not the controller.
RSpec.describe "Removed routes", type: :routing do

  it 'no longer routes GET /manufacturers' do
    expect(:get => '/manufacturers').not_to be_routable
  end

  # TTPLAT-3091 instance 2: the policy runner and its update_assets action.
  it 'no longer routes GET /policies/:id/runner' do
    expect(:get => '/policies/abc/runner').not_to be_routable
  end

  it 'no longer routes POST /policies/:id/update_assets' do
    expect(:post => '/policies/abc/update_assets').not_to be_routable
  end
end
