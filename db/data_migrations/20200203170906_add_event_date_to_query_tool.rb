class AddEventDateToQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_or_create_by(
        name: 'event_date',
        label: 'Event Date',
        query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (History Log)'),
        filter_type: 'date'
    )
    qf.query_asset_classes << QueryAssetClass.find_by(table_name: 'most_recent_asset_events')

    # reassign new query field to saved query fields that use the old field

    disposition_field = QueryField.find_by(name: "disposition_date")

    SavedQueryField.where(query_field: disposition_field).each do |sqf|
      sqf.update(query_field: qf)
      output_fields = sqf.saved_query.ordered_output_field_ids
      if output_fields.include? disposition_field.id
        sqf.saved_query.update(ordered_output_field_ids: output_fields.map{|id| id == disposition_field.id ? qf.id : id})
      end
    end

    QueryFilter.where(query_field: disposition_field).update_all(query_field_id: qf.id)

    disposition_field&.destroy
  end
end