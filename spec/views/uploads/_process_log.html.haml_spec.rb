require 'rails_helper'

describe "uploads/_process_log.html.haml", :type => :view do
  it 'log' do
    assign(:upload, create(:upload, :processing_log => 'test log 123'))
    render

    expect(rendered).to have_content('test log 123')
  end
end
