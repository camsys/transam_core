require 'rails_helper'

RSpec.describe Customer, :type => :model do
  let(:test_customer) { create(:customer) }

  describe 'associations' do
    it 'has a license type' do
      expect(test_customer).to belong_to(:license_type)
    end
    it 'has orgs' do
      expect(test_customer).to have_many(:organizations)
    end
  end

  it '.to_s' do
    expect(test_customer.to_s).to eq(test_customer.name)
  end
end
