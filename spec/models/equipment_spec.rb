require 'rails_helper'

RSpec.describe Equipment, :type => :model do

  let(:test_equipment) { create(:equipment_asset) }

  describe 'validations' do
    describe 'quantity' do
      it 'must exist' do
        test_equipment.quantity = nil
        expect(test_equipment.valid?).to be false
      end
      it 'must be a number' do
        test_equipment.quantity = 'abc'
        expect(test_equipment.valid?).to be false
      end
      it 'must be greater than 0' do
        test_equipment.quantity = -2
        expect(test_equipment.valid?).to be false
      end
    end
    it 'must have quanity units' do
      test_equipment.quantity_units = nil
      expect(test_equipment.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Equipment.allowable_params).to eq([
      :quantity,
      :quantity_units
    ])
  end

  it '.cost' do
    expect(test_equipment.cost).to eq(test_equipment.purchase_cost)
  end

  it '.set_defaults' do
    test_equipment = Equipment.new

    expect(test_equipment.quantity).to eq(1)
    expect(test_equipment.quantity_units).to eq(Uom::UNIT)
  end
end
