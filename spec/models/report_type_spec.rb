require 'rails_helper'

RSpec.describe ReportType, :type => :model do

  let(:test_type) { ReportType.first }

  describe 'associations' do
    it 'reports of each type' do
      expect(test_type).to have_many(:reports)
    end
  end

  it '.to_s' do
    expect(test_type.to_s).to eq(test_type.name)
  end
end
