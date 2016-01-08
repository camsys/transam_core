require 'rails_helper'

describe "assets/_new_form.html.haml", :type => :view do
  it 'fields' do
    test_user = create(:admin)
    allow(controller).to receive(:current_user).and_return(test_user)
    test_user.organizations = [test_user.organization, create(:organization)]
    test_user.save!
    assign(:asset_types, AssetType.all)
    render

    expect(rendered).to have_field('organization_id')
    expect(rendered).to have_field('asset_subtype')
  end
end
