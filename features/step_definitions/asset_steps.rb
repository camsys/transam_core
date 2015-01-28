### GIVEN ###

# create an equipment asset
Given(/^an? \[(.*?)\] exists$/) do |obj|
  o = Organization.last
  test_asset = FactoryGirl.create(:equipment_asset, :organization => o)
  policy = Policy.find_by_organization_id(o.id)

  if PolicyItem.where('policy_id = ? AND asset_subtype_id = ?', policy.id, test_asset.asset_subtype.id).count == 0
    FactoryGirl.create(:policy_item, :policy => policy, :asset_subtype => test_asset.asset_subtype)
  end
end
