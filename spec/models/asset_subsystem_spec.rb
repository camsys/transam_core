require 'rails_helper'

RSpec.describe AssetSubsystem, :type => :model do

  let(:test_subsystem) { create(:asset_subsystem) }

  describe 'associations' do
    it 'belongs to an asset type' do
      expect(AssetSubsystem.column_names).to include('asset_type_id')
    end
    it 'has many asset event asset subsystems' do
      expect(AssetEventAssetSubsystem.column_names).to include('asset_subsystem_id')
    end
  end

  describe 'validations' do
    it 'must have a name' do
      test_subsystem.name = nil

      expect(test_subsystem.valid?).to be false
    end
  end

  it '.to_s' do
    expect(test_subsystem.to_s).to eq(test_subsystem.name)
  end
end
