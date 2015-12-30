require 'rails_helper'

describe "asset_groups/_asset_summary.html.haml", :type => :view do
  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end
  
  it 'actions' do
    test_group = create(:asset_group)
    test_asset = create(:buslike_asset)
    test_asset2 = create(:buslike_asset)
    test_asset.asset_groups << test_group
    test_asset.save!
    test_asset2.asset_groups << test_group
    test_asset2.save!
    assign(:data, AssetSubtypeReport.new.get_data_from_collection(test_group.assets))
    assign(:total_assets, test_group.assets.count)
    render

    expect(rendered).to have_content('2')
    expect(rendered).to have_content('100%')
  end
end
