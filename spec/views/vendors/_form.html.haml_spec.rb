require 'rails_helper'

describe "vendors/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:vendor, Vendor.new)
    render

    expect(rendered).to have_field('vendor_name')
    expect(rendered).to have_field('vendor_address1')
    expect(rendered).to have_field('vendor_address2')
    expect(rendered).to have_field('vendor_city')
    expect(rendered).to have_field('vendor_state')
    expect(rendered).to have_field('vendor_zip')
    expect(rendered).to have_field('vendor_phone')
    expect(rendered).to have_field('vendor_fax')
    expect(rendered).to have_field('vendor_url')
  end
end
