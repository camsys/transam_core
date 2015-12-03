require 'rails_helper'

RSpec.describe AssetDispositionService, :type => :service do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_service) { AssetDispositionService.new }

  it '.disposition_list' do
    test_asset = create(:buslike_asset, :scheduled_replacement_year => 2020)

    results = test_service.disposition_list([test_asset.organization.id], 2020, test_asset.asset_type.id, test_asset.asset_subtype.id)

    expect(results).to include(test_asset)

    test_asset.update!(:disposition_date => Date.today)
    results = test_service.disposition_list([test_asset.organization.id], 2020, test_asset.asset_type.id, test_asset.asset_subtype.id)

    expect(results).not_to include(test_asset)

  end
end
