require 'rails_helper'

RSpec.describe AssetTag, :type => :model do

  let(:test_org) { create(:organization) }
  let(:test_tag) { AssetTag.create!(:asset => create(:buslike_asset, :organization => test_org), :user => create(:normal_user, :organization => test_org)) }

  describe 'associations' do
    it 'has an asset' do
      expect(test_tag).to belong_to(:asset)
    end
    it 'has a user' do
      expect(test_tag).to belong_to(:user)
    end
  end

  describe 'validations' do
    it 'must have an asset' do
      test_tag.asset = nil
      expect(test_tag.valid?).to be false
    end
    it 'must have a user' do
      test_tag.user = nil
      expect(test_tag.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(AssetTag.allowable_params).to eq([])
  end
end
