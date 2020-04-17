require 'rails_helper'

RSpec.describe Activity, :type => :model do

  let(:test_user) { create(:normal_user) }
  let(:test_asset) { create(:buslike_asset_basic_org) }

  describe 'viewable' do

    it 'responds to viewable_by?' do
      expect(test_asset.viewable_by?(test_user)).to eq(true)
    end

  end

end