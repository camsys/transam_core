require 'rails_helper'

RSpec.describe Manufacturer, :type => :model do

  let(:test_manufacturer) { create(:manufacturer) }
  let(:bus) { create(:buslike_asset) }

  before(:each) do
    Manufacturer.destroy_all
  end

  describe 'associations' do
    it 'has many assets' do
      expect(test_manufacturer).to have_many(:assets)

      bus.update!(:manufacturer => test_manufacturer)
      bus2 = create(:buslike_asset, :manufacturer => create(:manufacturer))

      expect(test_manufacturer.assets).to include(bus)
      expect(test_manufacturer.assets).not_to include(bus2)
      expect(test_manufacturer.asset_count(bus.organization)).to eq(1)
    end
  end

  describe '#search' do
    describe 'exact' do
      it 'name' do
        expect(Manufacturer.search(test_manufacturer.name,test_manufacturer.filter)).to eq(test_manufacturer)
      end
      it 'code' do
        expect(Manufacturer.search(test_manufacturer.code,test_manufacturer.filter)).to eq(test_manufacturer)
      end
    end
    describe 'like' do
      it 'name' do
        expect(Manufacturer.search(test_manufacturer.name[0],test_manufacturer.filter, false)).to eq(test_manufacturer)
      end
      it 'code' do
        expect(Manufacturer.search(test_manufacturer.code[0],test_manufacturer.filter, false)).to eq(test_manufacturer)
      end
    end
  end

  it '.full_name' do
    expect(test_manufacturer.full_name).to eq(test_manufacturer.name)
  end

  it '.to_s' do
    expect(test_manufacturer.to_s).to eq("#{test_manufacturer.code}-#{test_manufacturer.name}")
  end
end
