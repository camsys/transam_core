require 'rails_helper'

RSpec.describe FileStatusType, :type => :model do

  let(:test_type) { FileStatusType.first }

  it '.to_s' do
    expect(test_type.to_s).to eq(test_type.name)
  end
end
