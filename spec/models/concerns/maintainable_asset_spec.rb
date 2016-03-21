require 'rails_helper'

RSpec.describe Asset, :type => :model do

  let(:test_asset) { create(:buslike_asset) }

  describe 'associations' do
    it 'has many maintenance updates' do
      expect(test_asset).to have_many(:maintenance_updates)
    end
  end

  it '.update_maintenance' do
    test_asset.maintenance_updates.create!(attributes_for(:maintenance_update_event, :maintenance_type_id => create(:maintenance_type).id))
    test_asset.update_maintenance
    expect(test_asset.last_maintenance_date).to eq(Date.today)
  end

end
