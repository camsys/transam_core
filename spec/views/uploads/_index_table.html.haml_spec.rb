require 'rails_helper'

describe "uploads/_index_table.html.haml", :type => :view do
  it 'list' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_upload = create(:upload)
    assign(:uploads, [test_upload])
    render

    expect(rendered).to have_content(test_upload.object_key)
    expect(rendered).to have_content(test_upload.organization.short_name)
    expect(rendered).to have_content(test_upload.original_filename)
    expect(rendered).to have_content(test_upload.file_content_type.to_s)
    expect(rendered).to have_content(test_upload.file_status_type.to_s)
    expect(rendered).to have_content(test_upload.user.name)
  end
end
