require 'rails_helper'

RSpec.describe "system_configs/show", type: :view do
  before(:each) do
    @system_config = assign(:system_config, SystemConfig.instance)
  end

  it "renders attributes in <p>" do
    render
  end
end
