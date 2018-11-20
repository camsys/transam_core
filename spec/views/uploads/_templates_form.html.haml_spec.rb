require 'rails_helper'

describe "uploads/_templates_form.html.haml", :type => :view do
  it 'form' do
    # Add equipment type for uploads template form
    AssetType.create!({:active => 1, :name => 'Maintenance Equipment',    :description => 'Maintenance Equipment',      :class_name => 'Equipment',         :map_icon_name => "blueIcon",     :display_icon_name => "fa fa-wrench"})

    test_user = create(:admin)
    test_user.organizations = [test_user.organization, create(:organization)]
    test_user.save!
    allow(controller).to receive(:current_user).and_return(test_user)
    assign(:asset_types, [])
    assign(:organization_list, [test_user.organization.id, create(:organization).id])
    render

    expect(rendered).to have_field('template_proxy_organization_id')
    expect(rendered).to have_field('template_proxy_file_content_type_id')
    expect(rendered).to have_field('template_proxy_asset_seed_class_id')
  end
end
