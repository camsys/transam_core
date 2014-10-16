require 'rails_helper'

RSpec.describe Uom, :type => :model do

  describe '#valid?' do
    it 'validates correctly' do
      expect(Uom.valid? Uom::MILE).to eq(true)
    end
    it 'validates correctly' do
      expect(Uom.valid? Uom::MILE).to eq(true)
      expect(Uom.send(:valid?, Uom::METER)).to eq(true)
    end
    it 'validates correctly' do
      expect(Uom.valid? 'cubits').to eq(false)
    end
    it 'validates correctly' do
      expect(Uom.valid? 'monkeys').to eq(false)
    end

  end

  describe '#convert?' do
    it 'converts correctly' do
      expect(Uom.convert(1, Uom::MILE, Uom::METER)).to eq(1609.3472186944373)
    end
    it 'converts correctly' do
      expect(Uom.convert(0.25, Uom::MILE, Uom::METER)).to eq(402.3368046736093)
    end
    it 'converts correctly' do
      expect(Uom.convert(1, Uom::METER, Uom::MILE)).to eq(0.0006213699494949495)
    end
    it 'fails to convert' do
      expect { Uom.convert(1, Uom::METER, 'monkeys')}.to raise_error(ArgumentError)
    end

  end

end
