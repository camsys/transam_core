require 'rails_helper'

describe "uploads/_upload_form.html.haml", :type => :view do
  it 'form' do
    test_user = create(:admin)
    test_user.organizations = [test_user.organization, create(:organization)]
    test_user.save!
    allow(controller).to receive(:current_user).and_return(test_user)
    assign(:upload, Upload.new)
    assign(:organization_list, [test_user.organization.id, create(:organization).id])
    render

    expect(rendered).to have_field('upload_organization_id')
    expect(rendered).to have_field('upload_file')
    expect(rendered).to have_field('upload_file_content_type_id')
  end
end
