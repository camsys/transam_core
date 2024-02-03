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

    # Drop view that is blocking upgrade. Restore with 'rake transam_spatial:update_geometry_view
    execute <<-SQL
      DROP VIEW IF EXISTS geometry_transam_assets_view
    SQL
    
    # This view is left with "Illegal mix of collations for operation 'UNION'". Restore with 'rake transam_core:restore_parent_view
    execute <<-SQL
      DROP VIEW IF EXISTS parent_transam_assets_view
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
  end
end
