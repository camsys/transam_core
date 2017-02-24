require 'rails_helper'

describe "dashboards/_queues.html.haml", :type => :view do
  it 'queues' do
    test_user = create(:admin)
    allow(controller).to receive(:current_user).and_return(test_user)
    assign(:organization_list, Organization.ids)
    assign(:queues, [{:name => "Tagged Assets", :view => 'assets_queue', :objs => test_user.assets}])
    render

    expect(rendered).to have_link('Tagged Assets')
    expect(rendered).to have_content('0')
  end
end
