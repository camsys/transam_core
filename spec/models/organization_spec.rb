require 'rails_helper'

RSpec.describe Organization, :type => :model do
  let(:test_org) { build_stubbed(:organization) }

  it '.to_param' do
    expect(test_org.to_param).to eq(test_org.short_name)
  end

  it 'associations' do
    expect(test_org).to belong_to(:customer)
    expect(test_org).to belong_to(:organization_type)
  end

  describe 'validations' do
    it 'must have a customer' do
      test_org.customer = nil
      expect(test_org.valid?).to be false
    end
    it 'must have a type' do
      test_org.organization_type = nil
      expect(test_org.valid?).to be false
    end
    it 'must have a name' do
      test_org.name = nil
      expect(test_org.valid?).to be false
    end
    it 'must have a short name' do
      test_org.short_name = nil
      expect(test_org.valid?).to be false
    end
    it 'must be a unique short name' do
      test_org = create(:organization)
      test_org2 = build_stubbed(:organization, :short_name => test_org.short_name)
      expect(test_org2.valid?).to be false
    end
    it 'must have a address' do
      test_org.address1 = nil
      expect(test_org.valid?).to be false
    end
    it 'must have a city' do
      test_org.city = nil
      expect(test_org.valid?).to be false
    end
    it 'must have a state' do
      test_org.state = nil
      expect(test_org.valid?).to be false
    end
    it 'must have a zip' do
      test_org.zip = nil
      expect(test_org.valid?).to be false
    end
    it 'must have a phone' do
      test_org.phone = nil
      expect(test_org.valid?).to be false
    end
    it 'must have a url' do
      test_org.url = nil
      expect(test_org.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Organization.allowable_params).to eq([
      :customer_id,
      :organization_type_id,
      :external_id,
      :license_holder,
      :name,
      :short_name,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :phone,
      :fax,
      :url,
      :active
    ])
  end

  describe '.technical_contact' do
    it 'none' do
      expect(test_org.technical_contact).to be nil
    end
    it 'technical contact' do
      test_user = create(:technical_contact, :organization => test_org)

      expect(test_org.technical_contact).to eq(test_user)
    end
  end

  describe '.users_with_role' do
    it 'none' do
      results = test_org.users_with_role 'admin'
      expect(results.count).to eq(0)
    end
    it 'get users with a role' do
      test_user = create(:admin, :organization => test_org)

      expect(test_org.users_with_role 'admin').to include(test_user)
    end
  end

  it '.asset_type_counts' do
    expect(test_org.asset_type_counts).to eq({})

    test_asset_type = create(:asset_type)
    create(:buslike_asset, :asset_type => test_asset_type, :organization => test_org)

    expect(test_org.asset_type_counts).to eq({test_asset_type.id=>1})
  end
  it '.asset_subtype_counts' do
    test_asset_type = create(:asset_type)
    test_asset_subtype = create(:asset_subtype, :asset_type => test_asset_type)

    expect(test_org.asset_subtype_counts test_asset_type).to eq({})

    create(:buslike_asset, :asset_type => test_asset_type, :asset_subtype => test_asset_subtype, :organization => test_org)

    expect(test_org.asset_subtype_counts test_asset_type.id).to eq({test_asset_subtype.id=>1})
  end

  it '.coded_name' do
    expect(test_org.coded_name).to eq("#{test_org.short_name}-#{test_org.name}")
  end
  it '.object_key' do
    expect(test_org.object_key).to eq(test_org.short_name)
  end
  it '.to_s' do
    expect(test_org.to_s).to eq(test_org.short_name)
  end

  it '.has_assets?' do
    expect(test_org.has_assets?).to be false
  end
end
