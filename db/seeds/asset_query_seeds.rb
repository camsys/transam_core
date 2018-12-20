### Load asset query configurations
puts "======= Loading core asset query configurations ======="

# Query Asset Classes
asset_table = QueryAssetClass.find_or_create_by(table_name: 'transam_assets')

# Query Category and fields
category_fields = {
  'Identification & Classification': [
    {
      name: 'organization_id',
      label: 'Organization',
      filter_type: 'multi_select'
    },
    {
      name: 'asset_tag',
      label: 'Asset ID / Segment ID',
      filter_type: 'type_ahead'
    },
    {
      name: 'external_id',
      label: 'External ID',
      filter_type: 'type_ahead'
    },
    {
      name: 'asset_subtype_id',
      label: 'Subtype',
      filter_type: 'multi_select'
    },
    {
      name: 'description',
      label: 'Description / Segment Name',
      filter_type: 'type_ahead'
    }
  ],

  'Characteristics': [
    {
      name: 'manufacturer_id',
      label: 'Manufacturer',
      filter_type: 'type_ahead'
    },
    {
      name: 'other_manufacturer',
      label: 'Manufacturer (Other)',
      filter_type: 'type_ahead',
      depends_on: ['manufacturer_id']
    },
    {
      name: 'manufacturer_model_id',
      label: 'Model',
      filter_type: 'type_ahead'
    },
    {
      name: 'other_manufacturer_model',
      label: 'Model (Other)',
      filter_type: 'type_ahead',
      depends_on: ['manufacturer_model_id']
    },
    {
      name: 'manufacture_year',
      label: 'Year of Construction / Year of Manufacture',
      filter_type: 'numeric'
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
      filter_type: 'multi_select'
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
      filter_type: 'multi_select'
    }
  ],

  'Life Cycle (Depreciation)': [
    {
      name: 'depreciable',
      label: 'Asset is Depreciable?',
      filter_type: 'multi_select'
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
      label: 'Date of Disposition Request',
      filter_type: 'date'
    }
  ]
}

category_fields.each do |category_name, fields|
  qc = QueryCategory.find_or_create_by(name: category_name)
  fields.each do |field|
    qf = QueryField.find_or_create_by(
      name: field[:name], 
      label: field[:label], 
      query_category: qc, 
      filter_type: field[:filter_type],
      depends_on: field[:depends_on]
    )
    qf.query_asset_classes << asset_table
  end
end

