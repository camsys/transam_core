require 'rails_helper'

describe "activities/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:activity, Activity.new)
    render

    expect(rendered).to have_field('activity_name')
    expect(rendered).to have_field('activity_description')
    expect(rendered).to have_field('activity_job_name')
    expect(rendered).to have_field('activity_frequency_quantity')
    expect(rendered).to have_field("activity_frequency_type_id")
    expect(rendered).to have_field('activity_execution_time')
    expect(rendered).to have_field('activity_show_in_dashboard')
    expect(rendered).to have_field('activity_active')
    expect(rendered).to have_field('activity_start_date')
    expect(rendered).to have_field('activity_end_date')
  end
end
