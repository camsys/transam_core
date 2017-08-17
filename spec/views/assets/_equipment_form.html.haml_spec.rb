require 'rails_helper'

describe "assets/_equipment_form.html.haml", :type => :view do
  it 'fields' do
    test_asset_type =  create(:asset_type, :class_name => 'Equipment')
    assign(:asset, Equipment.new(:asset_type => test_asset_type))
    test_policy = create(:policy, parent_id: nil)
    create(:policy_asset_type_rule, policy_id: test_policy.id, asset_type_id: test_asset_type.id, condition_rollup_calculation_type_id: 1)
    render

    expect(rendered).to have_xpath('//input[@id="asset_asset_type_id"]')
    expect(rendered).to have_xpath('//select[@id="asset_asset_subtype_id"]')
    expect(rendered).to have_xpath('//input[@id="asset_organization_id"]')
    expect(rendered).to have_field("asset_asset_tag")
    expect(rendered).to have_field("asset_external_id")
    expect(rendered).to have_field("asset_description")
    expect(rendered).to have_field("asset_quantity")
    expect(rendered).to have_field("asset_quantity_units")
    expect(rendered).to have_field("asset_manufacturer_id")
    expect(rendered).to have_field("asset_manufacturer_model")
    expect(rendered).to have_field("asset_manufacture_year")
    expect(rendered).to have_field("asset_serial_number")
    expect(rendered).to have_field("asset_purchase_cost")
    expect(rendered).to have_field('asset_purchase_date')
    expect(rendered).to have_field('asset_warranty_date')
    expect(rendered).to have_field('asset_in_service_date')
    expect(rendered).to have_field('asset_purchased_new_true')
    expect(rendered).to have_field('vendor_name')
  end
end
