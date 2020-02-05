class AddEventByToQueryTool < ActiveRecord::DataMigration
  def up
    query_view_sql = <<-SQL
      CREATE OR REPLACE VIEW most_recent_asset_events_updated_by_user_view AS
        SELECT
          mrae.asset_event_id, mrae.base_transam_asset_id, CONCAT(u.first_name, ' ', u.last_name) AS event_by
        FROM query_tool_most_recent_asset_events_for_type_view AS mrae
        LEFT JOIN asset_events AS ae ON ae.id = mrae.asset_event_id
        LEFT JOIN transam_assets AS ta  ON ta.id = mrae.base_transam_asset_id
        LEFT JOIN users AS u ON u.id = ae.updated_by_id;
    SQL
    ActiveRecord::Base.connection.execute query_view_sql

    updated_by_table = QueryAssetClass.find_or_create_by(
        table_name: 'most_recent_asset_events_updated_by_user_view',
        transam_assets_join: "left join most_recent_asset_events_updated_by_user_view on most_recent_asset_events_updated_by_user_view.base_transam_asset_id = transam_assets.id"
    )
    qf = QueryField.find_or_create_by(
        name: 'event_by',
        label: 'Event By',
        query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (History Log)'),
        filter_type: 'text'
    )
    qf.query_asset_classes << updated_by_table
  end
end