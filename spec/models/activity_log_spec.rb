require 'rails_helper'

RSpec.describe ActivityLog, :type => :model do

  let(:test_log) { create(:activity_log) }

  describe 'associations' do
    it 'has an org' do
      expect(test_log).to belong_to(:organization)
    end
    it 'has a user' do
      expect(test_log).to belong_to(:user)
    end
  end
  describe 'validations' do
    it 'must have an org' do
      test_log.organization = nil

      expect(test_log.valid?).to be false
    end
  end

  it '.to_s' do
    expect(test_log.to_s).to eq(test_log.item_type)
  end

end
