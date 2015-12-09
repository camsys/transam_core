require 'rails_helper'

describe "vendors/_summary.html.haml", :type => :view do
  it 'info' do
    allow_any_instance_of(Vendor).to receive(:full_address).and_return('true')
    test_vendor = create(:vendor, :address1 => '123 Main St', :city => 'Boston', :state => 'MA', :zip => '02140', :phone => '1234567890', :fax => '9876543210', :url => 'www.web.com')
    render 'vendors/summary', :vendor => test_vendor

    expect(rendered).to have_content('123 Main St')
    expect(rendered).to have_content('(123) 456-7890')
    expect(rendered).to have_content('(987) 654-3210')
    expect(rendered).to have_content('www.web.com')
  end
end
