require 'rails_helper'

describe "uploads/_summary.html.haml", :type => :view do
  it 'info' do
    test_upload = create(:upload)
    render 'uploads/summary', :upload  => test_upload

    expect(rendered).to have_content(test_upload.original_filename)
    expect(rendered).to have_content(test_upload.file_content_type.to_s)
    expect(rendered).to have_content(test_upload.file_status_type.to_s)
  end
end
