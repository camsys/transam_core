require 'rails_helper'

describe "notices/_actions.html.haml", :type => :view do
  it 'actions for current notice' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    test_notice = create(:notice, :end_datetime => DateTime.current.to_date+1.day)
    assign(:notice, test_notice)
    render

    expect(rendered).to have_link('Update this notice')
    expect(rendered).to have_link('Deactivate this notice')
    expect(rendered).to have_link('Remove this notice')
  end
  it 'reactivate notice' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    test_notice = create(:notice, :display_date => Date.today - 2.days, :display_hour => 10, :end_date => Date.today - 1.day, :end_hour => 10)
    assign(:notice, test_notice)
    render

    expect(rendered).to have_link('Reactivate this notice')
  end
end
