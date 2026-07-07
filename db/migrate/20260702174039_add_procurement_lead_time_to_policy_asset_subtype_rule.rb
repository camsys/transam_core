class AddProcurementLeadTimeToPolicyAssetSubtypeRule < ActiveRecord::Migration[5.2]
  def change
    add_column :policy_asset_subtype_rules, :procurement_lead_time, :integer, default: 0
  end
end
