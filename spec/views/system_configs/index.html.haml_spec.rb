require 'rails_helper'

RSpec.describe "system_configs/index", type: :view do
  before(:each) do
    assign(:system_configs, [
      SystemConfig.create!(),
      SystemConfig.create!()
    ])
  end

  it "renders a list of system_configs" do
    render
  end
end
