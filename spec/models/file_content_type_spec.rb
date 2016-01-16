require 'rails_helper'

RSpec.describe FileContentType, :type => :model do

  let(:test_type) { FileContentType.new(:name => 'Test Type') }

  it '.to_s' do
    expect(test_type.to_s).to eq(test_type.name)
  end
end
