require 'rails_helper'

describe "user_organization_filters/_summary.html.haml", :type => :view do
  it 'links' do
    test_filter = create(:user_organization_filter)
    # add 11 more(total 12) orgs to filter
    (1..11).each do
      test_filter.organizations << create(:organization)
    end
    test_filter.save!
    render 'user_organization_filters/summary', :filter => test_filter

    expect(rendered).to have_content(test_filter.name)
    expect(rendered).to have_content('12')
    expect(rendered).to have_content(test_filter.description)
  end
end
