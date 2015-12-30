require 'rails_helper'

describe "activities/_search_form.html.haml", :type => :view do
  it 'fields' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    render

    expect(rendered).to have_field('activity_flag_filter')
  end
end
