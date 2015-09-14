require 'rails_helper'

RSpec.describe Vendor, :type => :model do

  let(:test_vendor) { create(:vendor) }

  it 'must have an org' do
    expect(Vendor.column_names).to include("organization_id")
    test_vendor.organization = nil
    expect(test_vendor.valid?).to be false
  end
  it 'must have a name' do
    test_vendor.name = nil
    expect(test_vendor.valid?).to be false
  end

  it '#allowable_params' do
    expect(Vendor.allowable_params).to eq([
      :name,
      :organization_id,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :phone,
      :fax,
      :url,
      :active,
      :latitude,
      :longitude
    ])
  end

  it '.searchable_fields' do
    expect(test_vendor.searchable_fields).to eq([
      :object_key,
      :name,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :phone,
      :fax,
      :url
    ])
  end
  it '.to_s' do
    expect(test_vendor.to_s).to eq(test_vendor.name)
  end

  it '.set_defaults' do
    expect(test_vendor.active).to be true
    expect(test_vendor.state).to eq(SystemConfig.instance.default_state_code)
  end
end
