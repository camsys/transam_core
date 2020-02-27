class FixDispositionFieldsQueryTool < ActiveRecord::DataMigration
  def up
    fields = QueryField.joins(:query_asset_classes).where(query_asset_classes: {table_name: 'asset_events'}, column_filter_value: 'DispositionUpdateEvent')
    puts fields.count
    fields.update_all(column_filter: 'mrae_types.class_name')

    QueryFieldAssetClass.where(query_field_id: fields.pluck(:id)).update_all(query_asset_class_id: QueryAssetClass.find_by(table_name: 'most_recent_asset_events').id)
  end
end