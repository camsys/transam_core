class AddEarlyReplacementReasonTransamAssets < ActiveRecord::Migration[5.2]
  def change
    add_column :transam_assets, :early_replacement_reason, :text, after: :scheduled_replacement_cost
  end
end
