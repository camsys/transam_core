require 'rails_helper'

describe "notices/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:notice, Notice.new)
    render

    expect(rendered).to have_field('notice_subject')
    expect(rendered).to have_field('notice_summary')
    expect(rendered).to have_field('notice_details')
    expect(rendered).to have_field('notice_organization_id')
    expect(rendered).to have_field('notice_display_datetime_date')
    expect(rendered).to have_field('notice_display_datetime_hour')
    expect(rendered).to have_field('notice_end_datetime_date')
    expect(rendered).to have_field('notice_end_datetime_hour')
    expect(rendered).to have_field('notice_notice_type_id')
  end
end
