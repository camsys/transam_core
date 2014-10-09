require 'rails_helper'

RSpec.describe Asset, :type => :model do
  let(:test_asset_event) { build_stubbed(:test_asset_event) }
  let(:persisted_test_asset_event) { create(:test_asset_event) }



  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  # describe 'name' do
  #   it 'exists' do
  #     expect(test_asset_group.name).not_to be_empty
  #   end
  # #
  #   it 'is within the max length' do
  #     expect(test_asset_group).to be_valid
  #
  #     test_asset_group.name = 'x' * 65 # not within max length of 64
  #     expect(test_asset_group).not_to be_valid
  #   end
  # end
  # #
  # describe 'code' do
  #   it 'exists' do
  #     expect(test_asset_group.code).not_to be_empty
  #   end
  #
  #   it 'is within the max length' do
  #     expect(test_asset_group).to be_valid
  #
  #     test_asset_group.code = 'x' * 9 # not within max length of 8
  #     expect(test_asset_group).not_to be_valid
  #   end
  # end
  #
  # it 'belongs to exactly one organization' do
  #   expect(test_asset_group.organization.nil?).to eq(false)
  # end

end
