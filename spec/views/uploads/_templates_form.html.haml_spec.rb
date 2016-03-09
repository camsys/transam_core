require 'rails_helper'

describe "uploads/_templates_form.html.haml", :type => :view do
  it 'form' do
    test_user = create(:admin)
    test_user.organizations = [test_user.organization, create(:organization)]
    test_user.save!
    allow(controller).to receive(:current_user).and_return(test_user)
    assign(:asset_types, [])
    render

    expect(rendered).to have_field('template_proxy_organization_id')
    expect(rendered).to have_field('template_proxy_file_content_type_id')
    expect(rendered).to have_field('template_proxy_asset_type_id')
  end
end
