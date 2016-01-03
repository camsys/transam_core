require 'rails_helper'

describe "uploads/_history.html.haml", :type => :view do
  it 'info' do
    test_upload = create(:upload, :num_rows_failed => 4, :num_rows_replaced => 6, :num_rows_skipped => 3, :num_rows_added => 18, :num_rows_processed => 25, :processing_started_at => Time.new(2010,1,1,10,10), :processing_completed_at => Time.new(2010,1,1,10,11))
    assign(:upload, test_upload)
    render

    expect(rendered).to have_content('01/01/2010')
    expect(rendered).to have_content('01/01/2010')
    expect(rendered).to have_content(':10')
    expect(rendered).to have_content(':11')
    expect(rendered).to have_content('4')
    expect(rendered).to have_content('6')
    expect(rendered).to have_content('3')
    expect(rendered).to have_content('25')
  end
end
