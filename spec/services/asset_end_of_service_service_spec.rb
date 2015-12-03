require 'rails_helper'

RSpec.describe AssetEndOfServiceService, :type => :service do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_service) { AssetEndOfServiceService.new }

  it '.list' do
    test_asset = create(:buslike_asset, :scheduled_replacement_year => 2020)

    results = test_service.list([test_asset.organization.id], 2020, test_asset.asset_type.id, test_asset.asset_subtype.id)

    expect(results).to include(test_asset)

    test_asset.update!(:disposition_date => Date.today)
    results = test_service.list([test_asset.organization.id], 2020, test_asset.asset_type.id, test_asset.asset_subtype.id)

    expect(results).not_to include(test_asset)

  end
end
