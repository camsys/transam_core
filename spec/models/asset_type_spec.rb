require 'rails_helper'

RSpec.describe AssetType, :type => :model do

  let(:test_type) { create(:asset_type) }

  it '.full_name' do
    expect(test_type.full_name).to eq("#{test_type.name} - #{test_type.description}")
  end
  it '.to_s' do
    expect(test_type.to_s).to eq(test_type.name)
  end

  it 'responds to api_json' do
    expect(test_type).to respond_to(:api_json)
  end
end
