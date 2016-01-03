require 'rails_helper'

describe "uploads/create_template.html.haml", :type => :view do
  it 'download template' do
    assign(:filename, create(:upload).original_filename)
    assign(:filepath, Rails.root)
    render

    expect(rendered).to have_link('Download File')
  end
end
