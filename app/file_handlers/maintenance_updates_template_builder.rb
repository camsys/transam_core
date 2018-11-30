#------------------------------------------------------------------------------
#
# MaintenanceUpdatesTemplateBuilder
#
# Creates a template for capturing maintenance updates for existing inventory
#
#------------------------------------------------------------------------------
class MaintenanceUpdatesTemplateBuilder < TemplateBuilder

  SHEET_NAME = MaintenanceUpdatesFileHandler::SHEET_NAME

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)
    if @assets.nil?
      asset_seed_foreign_key = @asset_class_name.constantize.asset_seed_class_name.foreign_key

      assets =  @asset_class_name.constantize.operational.where(organization_id: @organization.id).where(asset_seed_foreign_key => @search_parameter.id)
    else
      assets = @assets
    end

    assets.each do |a|

      asset = Rails.application.config.asset_base_class_name.constantize.get_typed_asset(a)
      row_data  = []
      row_data << asset.object_key
      row_data << asset.organization.short_name
      row_data << asset.asset_tag
      row_data << asset.external_id
      row_data << asset.asset_subtype
      row_data << asset.description
      row_data << asset.try(:serial_number)

      if asset.respond_to? :maintenance_updates and asset.maintenance_updates.present?
        event = asset.maintenance_updates.last
        row_data << event.maintenance_type.name
        row_data << event.event_date
        row_data << event.current_mileage if include_mileage_columns?
      else
        row_data << nil # current_maintenance type
        row_data << nil # reprot date
        row_data << nil if include_mileage_columns?
      end
      row_data << nil # current_maintenance type
      row_data << nil # report date
      row_data << nil if include_mileage_columns? # current mileage
      row_data << nil # notes

      sheet.add_row row_data
    end
  end

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)

    # Add a lookup table worksheet and add the lookuptable values we need to it
    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    sheet.sheet_protection.password = 'transam'

    row = []
    @maintenance_types = MaintenanceType.active.pluck(:name)
    @maintenance_types.each do |x|
      row << x unless x.eql? "Unknown"
    end
    sheet.add_row row

  end

  # Performing post-processing
  def post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    sheet.sheet_protection

    # Merge Cells
    sheet.merge_cells("A1:G1")
    if include_mileage_columns?
      sheet.merge_cells("H1:N1")
    else
      sheet.merge_cells("H1:L1")
    end


    # This is used to get the column name of a lookup table based on its length
    alphabet = ('A'..'Z').to_a
    earliest_date = SystemConfig.instance.epoch

    # Maintenance Type
    sheet.add_data_validation((include_mileage_columns?) ? "K3:K1000": "J3:J1000", {
      :type => :list,
      :formula1 => "lists!$A$1:$#{alphabet[@maintenance_types.size]}$1",
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Maintenance type',
      :prompt => 'Only values in the list are allowed'})

    # Maintenance Date
    sheet.add_data_validation((include_mileage_columns?) ? "L3:L1000": "K1:K1000", {
        :type => :time,
        :operator => :greaterThan,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :allow_blank => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Maintenance Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    if include_mileage_columns?
      # Milage -Integer > 0
      sheet.add_data_validation("M3:M1000", {
        :type => :whole,
        :operator => :greaterThan,
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Milage must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Current mileage',
        :prompt => 'Only values greater than 0'})
    end


  end

  # header rows
  def header_rows
    title_row = [
        'Asset','','','','','','',
    ]

    title_row.concat([
        'Maintenance Report',
        '',
        '',
        '',
        '',
    ])

    if include_mileage_columns?
      title_row.concat([
          '',
          ''
      ])
    end

    detail_row = [
        'Object Key',
        'Agency',
        'Asset ID',
        'External ID',
        'Subtype',
        'Description'
    ]

    detail_row << 'Serial Number'

    if include_mileage_columns?
      detail_row.concat([
          # Maintenance Report Columns
          'Last Maintenance',
          'Last Maintenance Date',
          'Last Mileage',
          'Maintenance Performed',
          'Maintenance Date',
          'Mileage',
          'Notes'
      ])
    else
      detail_row.concat([
          # Maintenance Report Columns
          'Last Maintenance',
          'Last Maintenance Date',
          'Maintenance Performed',
          'Maintenance Date',
          'Notes'
      ])
    end

    [title_row, detail_row]
  end

  def column_styles
    styles = [
        {:name => 'asset_id_col', :column => 0},
        {:name => 'asset_id_col', :column => 1},
        {:name => 'asset_id_col', :column => 2},
        {:name => 'asset_id_col', :column => 3},
        {:name => 'asset_id_col', :column => 4},
        {:name => 'asset_id_col', :column => 5},
        {:name => 'asset_id_col', :column => 6},
    ]

    if include_mileage_columns?
      styles.concat([
        {:name => 'maintenance_type_locked',  :column => 7},
        {:name => 'maintenance_date_locked',  :column => 8},
        {:name => 'mileage_locked',           :column => 9},

        {:name => 'maintenance_type',         :column => 10},
        {:name => 'maintenance_date',         :column => 11},
        {:name => 'mileage',                  :column => 12},
        {:name => 'maintenance_notes',        :column => 13}
      ])
    else
      styles.concat([
        {:name => 'maintenance_type_locked',  :column => 7},
        {:name => 'maintenance_date_locked',  :column => 8},

        {:name => 'maintenance_type',         :column => 9},
        {:name => 'maintenance_date',         :column => 10},
        {:name => 'maintenance_notes',        :column => 11}
      ])
    end

    styles
  end

  def row_types
    types = [
        # Asset Id Block
        :string,
        :string,
        :string,
        :string,
        :string,
        :string,
    ]
    types << :string

    if include_mileage_columns?
      types.concat([
        :string,
        :date,
        :integer,
        :string,
        :date,
        :integer,
        :string
      ])
    else
      types.concat([
         :string,
         :date,
         :string,
         :date,
         :string
      ])
    end
    types
  end
  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super

    # Header Styles
    a << {:name => 'asset_id_col', :bg_color => "EBF1DE", :fg_color => '000000', :b => false, :alignment => { :horizontal => :center, :wrap_text => true }}

    a << {:name => 'maintenance_type_locked', :bg_color => "b0d6f1", :alignment => { :horizontal => :center, :wrap_text => true } , :locked => true }
    a << {:name => 'mileage_locked', :num_fmt => 3, :bg_color => "b0d6f1", :alignment => { :horizontal => :center, :wrap_text => true } , :locked => true }
    a << {:name => 'maintenance_date_locked', :format_code => 'MM/DD/YYYY', :bg_color => "b0d6f1", :alignment => { :horizontal => :center, :wrap_text => true } , :locked => true }
    a << {:name => 'maintenance_type', :bg_color => "b0d6f1", :alignment => { :horizontal => :center, :wrap_text => true } , :locked => false }
    a << {:name => 'mileage', :num_fmt => 3, :bg_color => "b0d6f1", :alignment => { :horizontal => :center, :wrap_text => true } , :locked => false }
    a << {:name => 'maintenance_date', :format_code => 'MM/DD/YYYY', :bg_color => "b0d6f1", :alignment => { :horizontal => :center, :wrap_text => true } , :locked => false }
    a << {:name => 'maintenance_notes', :bg_color => "b0d6f1", :alignment => { :horizontal => :left, :wrap_text => true } , :locked => false}

    a.flatten
  end

  def worksheet_name
    'Updates'
  end

  private

  def initialize(*args)
    super
  end

  def include_mileage_columns?

    if @asset_class_name.include? "Vehicle"
      true
    else
      false
    end
  end

end
