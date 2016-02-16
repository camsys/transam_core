require 'rails_helper'

RSpec.describe AssetGroup, :type => :model do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_asset_group) { create(:asset_group) }
  let(:test_asset) { create(:buslike_asset, :asset_groups => [test_asset_group]) }

  describe 'associations' do
    it 'belongs to an org' do
      expect(test_asset_group).to belong_to(:organization)
    end
    it 'HABTM assets' do
      expect(test_asset_group).to have_and_belong_to_many(:assets)
    end
  end
  describe 'validations' do
    it ' must have an org' do
      test_asset_group.organization = nil

      expect(test_asset_group.valid?).to be false
    end
    it 'must have a description' do
      test_asset_group.description = nil

      expect(test_asset_group.valid?).to be false
    end
    describe '#name' do
      it 'exists' do
        expect(test_asset_group.name).not_to be_empty
      end
    #
      it 'is within the max length' do
        expect(test_asset_group).to be_valid

        test_asset_group.name = 'x' * 65 # not within max length of 64
        expect(test_asset_group).not_to be_valid
      end
    end
    #
    describe '#code' do
      it 'exists' do
        expect(test_asset_group.code).not_to be_empty
      end

      it 'is within the max length' do
        expect(test_asset_group).to be_valid

        test_asset_group.code = 'x' * 9 # not within max length of 8
        expect(test_asset_group).not_to be_valid
      end
    end
  end

  it '#allowable_params' do
    expect(AssetGroup.allowable_params).to eq([
      :object_key,
      :organization_id,
      :name,
      :code,
      :description,
      :active
    ])
  end

  it '.homogeneous?' do
    test_asset.save!
    expect(test_asset_group.homogeneous?).to be true

    create(:buslike_asset, :asset_groups => [test_asset_group])
    expect(test_asset_group.homogeneous?).to be false
  end
  it 'asset_type_ids' do
    test_asset.save!

    expect(test_asset_group.asset_type_ids).to include(test_asset.asset_type_id)
  end
  it '.to_s' do
    expect(test_asset_group.to_s).to eq(test_asset_group.name)
  end
  it '.searchable_fields' do
    expect(test_asset_group.searchable_fields).to eq([
      :object_key,
      :name,
      :code,
      :description
    ])
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------


  it 'belongs to exactly one organization' do
    expect(test_asset_group.organization.nil?).to eq(false)
  end

  ################ TESTS THAT ASSOCIATIONS HOLD ON CRUD METHODS ################
  ### Four relationships to check: ###
  # asset_group belongs_to asset      asset.asset_groups.include? asset_group
  # asset has_many asset_groups
  # asset belongs_to asset_group      asset_group.assets.include? asset
  # asset_group has_many assets

  describe '#assets' do

    # Asset group with no assets
    it 'can have none' do
      expect(test_asset_group.assets.count).to eq(0)
    end

    it 'associations hold on asset create' do
      expect(test_asset.asset_groups.include? test_asset_group).to be true
      expect(test_asset_group.assets.include? test_asset).to be true
    end

    it 'associations hold on asset destroy' do
      test_asset_id = test_asset.id
      test_asset.destroy

      expect(test_asset.asset_groups.length).to eq(0)
      expect(test_asset_group.asset_ids.include? test_asset_id).to be false
    end
  end
end
