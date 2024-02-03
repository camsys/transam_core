class ConvertDatabaseToUtf8mb4 < ActiveRecord::Migration[5.2]
  def db
    ActiveRecord::Base.connection
  end

  def up
    return if Rails.env.production?

    # Remove problematical tables that are no longer needed
    [:capital_equipment_asset_table_views, :facility_primary_asset_table_views, :infrastructure_asset_table_views,
     :revenue_vehicle_asset_table_views, :service_vehicle_asset_table_views].each do |old_table|
      drop_table old_table if connection.table_exists?(old_table)
    end

    # Drop view that is blocking upgrade. Restore with 'rake app:transam_spatial:update_geometry_view
    execute <<-SQL
      DROP VIEW IF EXISTS geometry_transam_assets_view
    SQL
    
    execute "ALTER DATABASE `#{db.current_database}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    db.tables.each do |table|
      execute "ALTER TABLE `#{table}` ROW_FORMAT=DYNAMIC CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

      db.columns(table).each do |column|
        case column.sql_type
          when /([a-z]*)text/i
            default = (column.default.blank?) ? '' : "DEFAULT '#{column.default}'"
            null = (column.null) ? '' : 'NOT NULL'
            execute "ALTER TABLE `#{table}` MODIFY `#{column.name}` #{column.sql_type.upcase} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci #{default} #{null};"
          when /varchar\(([0-9]+)\)/i
            sql_type = column.sql_type.upcase
            default = (column.default.blank?) ? '' : "DEFAULT '#{column.default}'"
            null = (column.null) ? '' : 'NOT NULL'
            execute "ALTER TABLE `#{table}` MODIFY `#{column.name}` #{sql_type} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci #{default} #{null};"
        end
      end
    end

    # This view is left with "Illegal mix of collations for operation 'UNION'" Recreating fixes.
    parent_transam_assets_view = <<-SQL
      CREATE OR REPLACE VIEW parent_transam_assets_view AS
        SELECT transam_assets.organization_id, transam_assets.object_key as parent_id, transam_assets.asset_tag, facilities.facility_name, transam_assets.description,
        CONCAT(asset_tag, IF(facility_name IS NOT NULL OR description IS NOT NULL, ' : ', ''), IFNULL(facility_name,description)) AS parent_name
        FROM transam_assets
        INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
        LEFT JOIN `facilities` ON `transit_assets`.`transit_assetible_id` = `facilities`.`id` AND `transit_assets`.`transit_assetible_type` = 'Facility'
        WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' WHERE parent_id IS NOT NULL AND fta_asset_category_id != 4)
        UNION
        SELECT transam_assets.organization_id, transam_assets.object_key as parent_id, transam_assets.asset_tag, NULL, transam_assets.description,
        CONCAT(asset_tag, IF(description IS NOT NULL, ' : ', ''), description) AS parent_name
        FROM transam_assets
        INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
        INNER JOIN `infrastructures` ON `transit_assets`.`transit_assetible_id` = `infrastructures`.`id` AND `transit_assets`.`transit_assetible_type` = 'Infrastructure'
        WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' WHERE parent_id IS NOT NULL AND fta_asset_category_id = 4)
    SQL
    execute parent_transam_assets_view
    
  end
end
