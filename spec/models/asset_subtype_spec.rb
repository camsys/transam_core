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
end
