require 'rails_helper'

RSpec.describe NewUserService, :type => :service do

  let(:test_service) { NewUserService.new }

  it '.build' do
    test_org = create(:organization)
    test_user = test_service.build(attributes_for(:normal_user, :organization_id => test_org.id, :password => nil, :active => nil, :notify_via_email => nil))
    expect(test_user.password).not_to be nil
    expect(test_user.active).to be true
    expect(test_user.notify_via_email).to be true

  end
  it '.post_process' do
    # TODO
  end
end
