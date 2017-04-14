class AddReplacementStatus < ActiveRecord::Migration
  def change
    add_column :asset_events, :replacement_status_type_id, :string, after: :replacement_reason_type_id
    add_column :assets, :replacement_status_type_id, :string, after: :replacement_reason_type_id

    create_table :replacement_status_types do |t|
      t.string :name
      t.string :description
      t.boolean :active
    end

    replacement_status_types = [
        {:active => 1, :name => 'By Policy', :description => 'Asset will be replaced following tho policy and planner.'},
        {:active => 1, :name => 'Underway', :description => 'Asset is being replaced this fiscal year.'},
        {:active => 1, :name => 'None', :description => 'Asset is not being replaced.'}
    ]
    replacement_status_types.each do |type|
      ReplacementStatusType.create!(type)
    end

    AssetEventType.create!(name: 'Replacement status', class_name: 'ReplacementStatusUpdateEvent', job_name: 'AssetReplacementStatusUpdateJob', display_icon_name: 'fa fa-refresh', description: 'Replacement Status Update', active: true)
  end
end
