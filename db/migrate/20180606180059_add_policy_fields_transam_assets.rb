class AddPolicyFieldsTransamAssets < ActiveRecord::Migration[5.2]
  def change
    add_column :transam_assets, :policy_replacement_year, :integer, after: :location_id
    add_column :transam_assets, :scheduled_replacement_year, :integer, after: :policy_replacement_year
    add_column :transam_assets, :scheduled_replacement_cost, :integer, after: :scheduled_replacement_year
    add_column :transam_assets, :in_backlog, :boolean, after: :scheduled_replacement_cost

  end
end
