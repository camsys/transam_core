class AddConditionRollupCalculatorFields < ActiveRecord::Migration[5.2]
  def change

    # add condition rollup calculators
    create_table :condition_rollup_calculation_types do |t|
      t.string :name
      t.string :class_name
      t.string :description
      t.boolean :active
    end

    ConditionRollupCalculationType.destroy_all
    [
        {id: 1, name: 'Weighted Average', class_name: 'WeightedAverageConditionRollupCalculator', description: "Asset condition is calculated using a weighted average of its components' conditions."},
        {id: 2, name: 'Median', class_name: 'MedianConditionRollupCalculator', description: "Asset condition is calculated using the median of its components' conditions."},
        {name: 'Custom Weighted', class_name: 'CustomWeightedConditionRollupCalculator', description: "Asset condition is calculated using a weighted average of conditions where the weight is custom set."}
    ].each do |t|
      ConditionRollupCalculationType.create!(t)
    end

    # add column for calculator in policy asset type rule
    add_column :policy_asset_type_rules, :condition_rollup_calculation_type_id, :integer, index: true, after: :replacement_cost_calculation_type_id
    PolicyAssetTypeRule.update_all(condition_rollup_calculation_type_id: ConditionRollupCalculationType.ids.first)

    # add parent-child relationships so can rollup
    # current parent_id should be used for family tree, add column so location update event can use more appropriate field
    add_column :assets, :location_id, :integer
  end
end
