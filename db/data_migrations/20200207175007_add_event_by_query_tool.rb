class AddEventByQueryTool < ActiveRecord::DataMigration
  def up
    query_view_sql = <<-SQL
      CREATE OR REPLACE VIEW query_tool_most_recent_asset_events_for_type_view AS
        SELECT aet.id AS asset_event_type_id, aet.name AS asset_event_name, Max(ae.created_at) AS asset_event_created_time,
               ae.base_transam_asset_id, Max(ae.id) AS asset_event_id, ae.updated_by_id AS event_by
        FROM asset_events AS ae
        LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
        LEFT JOIN transam_assets AS ta  ON ta.id = ae.base_transam_asset_id
        GROUP BY aet.id, ae.base_transam_asset_id, ae.updated_by_id;
    SQL
    ActiveRecord::Base.connection.execute query_view_sql

    user_view_sql = <<-SQL
      CREATE OR REPLACE VIEW formatted_users_view AS
        SELECT id, CONCAT(first_name, " ", last_name) AS full_name, active
        FROM users
    SQL
    ActiveRecord::Base.connection.execute user_view_sql

    QueryField.find_by(name: 'event_by').destroy
    qf = QueryField.find_or_create_by(
        name: 'event_by',
        label: 'Event By',
        query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (History Log)'),
        filter_type: 'multi_select',
        query_association_class: QueryAssociationClass.find_or_create_by(table_name: 'formatted_users_view', display_field_name: 'full_name', id_field_name: 'id')
    )

    qf.query_asset_classes = QueryAssetClass.where(table_name: 'most_recent_asset_events')
  end
end