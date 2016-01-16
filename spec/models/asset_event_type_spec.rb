require 'rails_helper'

RSpec.describe AssetEventType, :type => :model do

  let(:test_type) { AssetEventType.first }

  it '.to_s' do
    expect(test_type.to_s).to eq(test_type.name)
  end
end
