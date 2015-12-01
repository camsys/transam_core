require 'rails_helper'

RSpec.describe Customer, :type => :model do
  let(:test_customer) { create(:customer) }

  describe 'associations' do
    it 'has a license type' do
      expect(Customer.column_names).to include('license_type_id')
    end
    it 'has orgs' do
      expect(Organization.column_names).to include('customer_id')
    end
  end

  it '.to_s' do
    expect(test_customer.to_s).to eq(test_customer.name)
  end
end
