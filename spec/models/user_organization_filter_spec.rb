require 'rails_helper'

RSpec.describe UserOrganizationFilter, :type => :model do

  let(:test_filter) { create(:user_organization_filter) }

  describe 'associations' do
    it 'has a user' do
      expect(test_filter).to belong_to(:user)
    end
    it 'HABTM organizations' do
      expect(test_filter).to have_and_belong_to_many(:organizations)
    end
  end

  describe 'validations' do
    it 'must have a user' do
      test_filter.user = nil
      expect(test_filter.valid?).to be false
    end
    describe 'name' do
      it 'must exist' do
        test_filter.name = nil
        expect(test_filter.valid?).to be false
      end
      it 'must be unique' do
        test_filter2 = build_stubbed(:user_organization_filter, :name => test_filter.name)
        expect(test_filter2.valid?).to be false
      end
    end
    it 'must have a description' do
      test_filter.description = nil
      expect(test_filter.valid?).to be false
    end

    it '.require at least one org', :skip do
      test_filter.organizations = []
      expect(test_filter.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(UserOrganizationFilter.allowable_params).to eq([
      :user_id,
      :name,
      :description,
      :organization_ids
    ])
  end

  it '.system_filter?' do
    test_filter.update!(:user_id => 2)
    expect(test_filter.system_filter?).to be false

    test_filter.update!(:user_id => 1)
    expect(test_filter.system_filter?).to be true
  end

  it 'clear habtm associations on destroy' do
    test_org = test_filter.organizations.first
    test_filter.destroy
    results = ActiveRecord::Base.connection.execute("SELECT * FROM `user_organization_filters_organizations` WHERE `user_organization_filter_id` = #{test_filter.id}")

    expect(results.count).to eq(0)
  end

  it '.set_defaults' do
    expect(UserOrganizationFilter.new.active).to be true
  end
end
