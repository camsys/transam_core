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

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen. The
  # example above only checked that api_json exists, never that it returned
  # anything, which is why the coverage screen still found it uncovered.
  it 'api_json returns id, name, and description' do
    expect(test_type.api_json).to eq({
      id: test_type.id,
      name: test_type.name,
      description: test_type.description
    })
  end
end
