class AddCustomWeightToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :weight, :integer, after: :created_by_id
    add_column :policy_asset_type_rules, :condition_rollup_weight, :integer, after: :pcnt_residual_value

    PolicyAssetTypeRule.where(policy_id: Policy.where('parent_id IS NULL').ids).update_all(condition_rollup_weight: 0)
  end
end
