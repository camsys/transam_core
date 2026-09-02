require 'rails_helper'

RSpec.describe AssetSubtype, :type => :model do

  let(:test_subtype) { create(:asset_subtype) }

  describe 'associations' do
    it 'has an asset type' do
      expect(test_subtype).to belong_to(:asset_type)
    end
  end

  describe 'validations' do
    it 'must have an asset type' do
      test_subtype.asset_type = nil

      expect(test_subtype.valid?).to be false
    end
  end

  it '.full_name' do
    expect(test_subtype.full_name).to eq("#{test_subtype.name} - #{test_subtype.description}")
  end
  it '.to_s' do
    expect(test_subtype.to_s).to eq(test_subtype.name)
  end

  it 'responds to api_json' do
    expect(test_subtype).to respond_to(:api_json)
  end

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen. The
  # example above only checked that api_json exists, never that it returned
  # anything, which is why the coverage screen still found it uncovered.
  it 'api_json returns id, name, description, and the asset_type api_json' do
    expect(test_subtype.api_json).to eq({
      id: test_subtype.id,
      asset_type: test_subtype.asset_type.api_json,
      name: test_subtype.name,
      description: test_subtype.description
    })
  end

end
