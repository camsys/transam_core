class AddCommentsToQueryTool < ActiveRecord::DataMigration
  def up
    most_recent_asset_events_table = QueryAssetClass.find_or_create_by(
        table_name: 'most_recent_asset_events',
        transam_assets_join: "left join query_tool_most_recent_asset_events_for_type_view mraev on mraev.base_transam_asset_id = transam_assets.id left join asset_events as most_recent_asset_events on most_recent_asset_events.id = mraev.asset_event_id left join asset_event_types as mrae_types on most_recent_asset_events.asset_event_type_id = mrae_types.id"
    )

    qf = QueryField.find_or_create_by(
        name: 'comments',
        label: 'Comments',
        query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (History Log)'),
        filter_type: 'text'
    )
    qf.query_asset_classes << most_recent_asset_events_table
  end
end