require 'rails_helper'

RSpec.describe Report, :type => :model do

  let(:test_report) { build_stubbed(:report) }

  describe 'associations' do
    it 'has a type' do
      expect(test_report).to belong_to(:report_type)
    end
  end

  it '.to_s' do
    expect(test_report.to_s).to eq(test_report.name)
  end

  it '.role_names' do
    test_report.roles = "A,B,C"
    expect(test_report.role_names).to eq(['A','B','C'])
  end
end
