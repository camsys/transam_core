### Load asset query configurations
puts "======= Loading core asset query configurations ======="

# transam_assets table
QueryAssetClass.find_or_create_by(table_name: 'transam_assets')

most_recent_view_sql = <<-SQL
      CREATE OR REPLACE VIEW query_tool_most_recent_asset_events_for_type_view AS
        SELECT
          aet.id AS asset_event_type_id, aet.name AS asset_event_name, Max(ae.created_at) AS asset_event_created_time,
          ae.base_transam_asset_id, Max(ae.id) AS asset_event_id
        FROM asset_events AS ae
        LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
        LEFT JOIN transam_assets AS ta  ON ta.id = ae.base_transam_asset_id
        GROUP BY aet.id, ae.base_transam_asset_id;
SQL
ActiveRecord::Base.connection.execute most_recent_view_sql

most_recent_asset_events_table = QueryAssetClass.find_or_create_by(
    table_name: 'most_recent_asset_events',
    transam_assets_join: "left join query_tool_most_recent_asset_events_for_type_view mraev on mraev.base_transam_asset_id = transam_assets.id left join asset_events as most_recent_asset_events on most_recent_asset_events.id = mraev.asset_event_id left join asset_event_types as mrae_types on most_recent_asset_events.asset_event_type_id = mrae_types.id"
)

# Query Category and fields
transam_assets_category_fields = {
  'Identification & Classification': [
    {
      name: 'organization_id',
      label: 'Organization',
      filter_type: 'multi_select',
      auto_show: true,
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      }
    },
    {
      name: 'asset_tag',
      label: 'Asset ID',
      filter_type: 'text'
    },
    {
      name: 'external_id',
      label: 'External ID',
      filter_type: 'text'
    },
    {
      name: 'asset_subtype_id',
      label: 'Subtype',
      filter_type: 'multi_select',
      association: {
        table_name: 'asset_subtypes',
        display_field_name: 'name'
      }
    },
    {
      name: 'description',
      label: 'Description / Segment Name',
      filter_type: 'text'
    }
  ],

  'Characteristics': [
    {
      name: 'manufacturer_id',
      label: 'Manufacturer',
      filter_type: 'text',
      pairs_with: 'other_manufacturer',
      association: {
        table_name: 'manufacturers',
        display_field_name: 'name'
      }
    },
    {
      name: 'other_manufacturer',
      label: 'Manufacturer (Other)',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'manufacturer_model_id',
      label: 'Model',
      filter_type: 'text',
      pairs_with: 'other_manufacturer_model',
      association: {
        table_name: 'manufacturer_models',
        display_field_name: 'name'
      }
    },
    {
      name: 'other_manufacturer_model',
      label: 'Model (Other)',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'manufacture_year',
      label: 'Year of Construction / Year of Manufacture',
      filter_type: 'numeric'
    },
    {
      name: 'quantity',
      label: 'Quantity',
      filter_type: 'numeric',
      pairs_with: 'quantity_unit'
    },
    {
      name: 'quantity_unit',
      label: 'Quantity Units',
      filter_type: 'text',
      hidden: true
    }
  ],

  'Funding': [
    {
      name: 'purchase_cost',
      label: 'Cost (Purchase)',
      filter_type: 'numeric'
    }
  ],

  'Procurement & Purchase': [
    {
      name: 'purchase_date',
      label: 'Purchase Date',
      filter_type: 'date'
    },
    {
      name: 'purchased_new',
      label: 'Purchased New',
      filter_type: 'boolean'
    },
    {
      name: 'vendor_id',
      label: 'Vendor',
      filter_type: 'text',
      pairs_with: 'other_vendor',
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      }
    },
    {
      name: 'other_vendor',
      label: 'Vendor (Other)',
      filter_type: 'text',
      hidden: true
    }
  ],

  'Operations': [
    {
      name: 'in_service_date',
      label: 'In Service Date',
      filter_type: 'date'
    }
  ],

  'Life Cycle (Replacement Status)': [
    {
      name: 'replacement_status_type_id',
      label: 'Replacement Status',
      filter_type: 'multi_select',
      association: {
        table_name: 'replacement_status_types',
        display_field_name: 'name'
      }
    }
  ],

  'Life Cycle (Depreciation)': [
    {
      name: 'depreciable',
      label: 'Asset is Depreciable?',
      filter_type: 'boolean'
    },
    {
      name: 'depreciation_start_date',
      label: 'Depreciation Start Date',
      filter_type: 'date'
    }
  ],

  'Life Cycle (Disposition & Transfer)': [
    {
      name: 'disposition_date',
      label: 'Date of Disposition',
      filter_type: 'date'
    }
  ]
}

most_recent_asset_events_fields = {
  "Life Cycle (History Log)": [
    {
      name: 'event_date',
      label: 'Event Date',
      filter_type: 'date'
    },
    {
      name: 'comments',
      label: 'Comments',
      filter_type: 'text'
    },
    {
      name: 'updated_at',
      label: 'Entry Date & Time',
      filter_type: 'date'
    }
  ]
}
# seeding
fields_data = {
  'transam_assets': transam_assets_category_fields,
  'most_recent_asset_events': most_recent_asset_events_fields
}

fields_data.each do |table_name, category_fields|
  query_asset_table = QueryAssetClass.find_by_table_name table_name
  category_fields.each do |category_name, fields|
    qc = QueryCategory.find_or_create_by(name: category_name)
    fields.each do |field|
      if field[:association]
        qac = QueryAssociationClass.find_or_create_by(field[:association])
      end
      qf = QueryField.find_or_create_by(
        name: field[:name], 
        label: field[:label], 
        query_category: qc, 
        query_association_class_id: qac.try(:id),
        filter_type: field[:filter_type],
        auto_show: field[:auto_show],
        hidden: field[:hidden],
        pairs_with: field[:pairs_with]
      )
      qf.query_asset_classes << query_asset_table
    end
  end
end

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

# Facility location
transam_assets_table = QueryAssetClass.find_by(table_name: 'transam_assets')
parent_association_table = QueryAssociationClass.find_or_create_by(table_name: 'parent_transam_assets_view', display_field_name: 'parent_name', id_field_name: 'parent_id')
facility_location_id_field = QueryField.find_or_create_by(
    name: 'location_id',
    label: 'Location (list of primary facilities)',
    query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (Location / Storage)'),
    filter_type: 'text',
    query_association_class: parent_association_table
)
facility_location_id_field.query_asset_classes << [transam_assets_table]

parent_field = QueryField.find_or_create_by(
    name: 'parent_id',
    label: 'Parent Asset',
    query_category: QueryCategory.find_or_create_by(name: 'Identification & Classification'),
    filter_type: 'text',
    query_association_class: parent_association_table
)
parent_field.query_asset_classes << [transam_assets_table]

# Event by
updated_by_sql = <<-SQL
      CREATE OR REPLACE VIEW most_recent_asset_events_updated_by_user_view AS
        SELECT
          mrae.asset_event_id, mrae.base_transam_asset_id, CONCAT(u.first_name, " ", u.last_name) AS event_by
        FROM query_tool_most_recent_asset_events_for_type_view AS mrae
        LEFT JOIN asset_events AS ae ON ae.id = mrae.asset_event_id
        LEFT JOIN transam_assets AS ta  ON ta.id = mrae.base_transam_asset_id
        LEFT JOIN users AS u ON u.id = ae.updated_by_id;
SQL
ActiveRecord::Base.connection.execute updated_by_sql

updated_by_table = QueryAssetClass.find_or_create_by(
    table_name: 'most_recent_asset_events_updated_by_user_view',
    transam_assets_join: "left join most_recent_asset_events_updated_by_user_view aeub on aeub.base_transam_asset_id = transam_assets.id"
)
event_by_field = QueryField.find_or_create_by(
    name: 'event_by',
    label: 'Event By',
    query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (History Log)'),
    filter_type: 'text'
    )
event_by_field.query_asset_classes << updated_by_table