class AddParentTransamAssetsQueryTool < ActiveRecord::DataMigration
  def up

    if ActiveRecord::Base.configurations[Rails.env]['adapter'].include? 'mysql2'
      parent_transam_assets_view_sql = <<-SQL
         CREATE OR REPLACE VIEW parent_transam_assets_view AS
  SELECT transam_assets.organization_id, transam_assets.id AS parent_id, transam_assets.asset_tag, transam_assets.description,
  CONCAT(asset_tag, IF(description IS NOT NULL, ' : ', ''), IFNULL(description,'')) AS parent_name
  FROM transam_assets
  WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets WHERE parent_id IS NOT NULL) OR transam_assets.id IN (SELECT DISTINCT location_id FROM transam_assets WHERE location_id IS NOT NULL)
      SQL
    elsif ActiveRecord::Base.configurations[Rails.env]['adapter'].include? 'post'
      parent_transam_assets_view_sql = <<-SQL
         CREATE OR REPLACE VIEW parent_transam_assets_view AS
  SELECT transam_assets.organization_id, transam_assets.id AS parent_id, transam_assets.asset_tag, transam_assets.description,
  CONCAT(asset_tag, CASE WHEN description IS NOT NULL THEN ' : ' ELSE '' END, description) AS parent_name
  FROM transam_assets
  WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets WHERE parent_id IS NOT NULL) OR transam_assets.id IN (SELECT DISTINCT location_id FROM transam_assets WHERE location_id IS NOT NULL)
      SQL
    end
    ActiveRecord::Base.connection.execute parent_transam_assets_view_sql


    parents_association_table = QueryAssociationClass.find_or_create_by(table_name: 'parent_transam_assets_view', display_field_name: 'parent_name', id_field_name: 'parent_id')

    parent_field = QueryField.find_or_create_by(
      name: 'parent_id',
      label: 'Parent Asset',
      query_category: QueryCategory.find_or_create_by(name: 'Identification & Classification'),
      filter_type: 'text',
      query_association_class: parents_association_table
    )

    parent_field.query_asset_classes << QueryAssetClass.find_by(table_name: 'transam_assets')


    bad_assoc = QueryAssociationClass.find_by(table_name: 'facilities', display_field_name: 'facility_name')


    location_query_field = QueryField.find_by(query_association_class: bad_assoc, name: 'location_id')

    if QueryField.where(query_association_class: bad_assoc).count == 1
      bad_assoc.destroy

      location_query_field.update!(query_association_class: parents_association_table)
    else
      "#{bad_assoc.inspect} used by more than one query field"
    end
  end
end