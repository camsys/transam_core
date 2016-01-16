require 'rails_helper'

RSpec.describe OrganizationType, :type => :model do

  let(:test_type) { OrganizationType.first }

  it '.to_s' do
    expect(test_type.to_s).to eq(test_type.name)
  end
end
