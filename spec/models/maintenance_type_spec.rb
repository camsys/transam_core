require 'rails_helper'

RSpec.describe MaintenanceType, :type => :model do

  before(:all) do
    create(:maintenance_type)
  end

  let(:test_type) { MaintenanceType.first }

  describe '#search' do
    it 'exact' do
      expect(MaintenanceType.search(test_type.description)).to eq(test_type)
    end
    it 'partial' do
      expect(MaintenanceType.search(test_type.description[0..1], false)).to eq(test_type)
    end
  end

  it '.to_s' do
    expect(test_type.to_s).to eq(test_type.name)
  end
end
