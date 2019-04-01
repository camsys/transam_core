require 'rails_helper'

RSpec.describe "system_configs/edit", type: :view do
  before(:each) do
    @system_config = assign(:system_config, SystemConfig.instance)
  end

  it "renders the edit system_config form" do
    render

    assert_select "form[action=?][method=?]", system_config_path(@system_config), "post" do
    end
  end
end
