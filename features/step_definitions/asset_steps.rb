### GIVEN ###

# create an equipment asset
Given(/^an \[equipment\] exists$/) do
  o = Organization.last
  test_asset = FactoryBot.create(:equipment_asset, :organization => o)
  policy = Policy.find_by_organization_id(o.id)

  if PolicyAssetSubtypeRule.where('policy_id = ? AND asset_subtype_id = ?', policy.id, test_asset.asset_subtype.id).count == 0
    FactoryBot.create(:policy_asset_subtype_rule, :policy => policy, :asset_subtype => test_asset.asset_subtype)
  end
end
