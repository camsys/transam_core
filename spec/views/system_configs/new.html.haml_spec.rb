require 'rails_helper'

RSpec.describe "system_configs/new", type: :view do
  before(:each) do
    assign(:system_config, SystemConfig.new())
  end

  it "renders new system_config form" do
    render

    assert_select "form[action=?][method=?]", system_configs_path, "post" do
    end
  end
end
