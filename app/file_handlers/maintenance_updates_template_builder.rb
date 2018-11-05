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
      assets =  @search_parameter.class_name.constantize.operational.where(organization_id: @organization.id).where(Rails.application.config.asset_seed_class_name.foreign_key => @search_parameter.id)
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
        row_data << event.current_mileage
        row_data << event.event_date
      else
        row_data << nil # current_maintenance type
        row_data << nil # current mileage
        row_data << nil # reprot date
      end
      row_data << nil # current_maintenance type
      row_data << nil # current mileage
      row_data << nil # report date
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
    sheet.merge_cells("H1:J1")
    sheet.merge_cells("K1:N1")


    # This is used to get the column name of a lookup table based on its length
    alphabet = ('A'..'Z').to_a
    earliest_date = SystemConfig.instance.epoch

    # Maintenance Type
    sheet.add_data_validation("K3:K1000", {
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

    # Milage -Integer > 0
    sheet.add_data_validation("L3:L1000", {
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

    # Maintenance Date
    sheet.add_data_validation("M3:M1000", {
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

  end

  # header rows
  def header_rows
    title_row = [
        'Asset','','','','','','','',
    ]
    title_row << ''

    title_row.concat([
        'Maintenance Report',
        '',
        '',
        '',
        '',
        '',
        ''
    ])


    detail_row = [
        'Object Key',
        'Agency',
        'Asset ID',
        'External ID',
        'Subtype',
        'Description'
    ]

    detail_row << 'Serial Number'

    detail_row.concat([
        # Maintenance Report Columns
        'Last Maintenance',
        'Last Mileage',
        'Last Maintenance Date',
        'Maintenance Performed',
        'Mileage',
        'Maintenance Date',
        'Notes'
    ])

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
        {:name => 'asset_id_col', :column => 7}
    ]

    styles.concat([
      {:name => 'maintenance_type_locked',  :column => 8},
      {:name => 'mileage_locked',           :column => 9},
      {:name => 'maintenance_date_locked',  :column => 10},
      {:name => 'maintenance_type',         :column => 11},
      {:name => 'mileage',                  :column => 12},
      {:name => 'maintenance_date',         :column => 13},
      {:name => 'maintenance_notes',        :column => 14}
    ])

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

    types.concat([
      :string,
      :integer,
      :date,
      :string,
      :integer,
      :date,
      :string
    ])
    types
  end
  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super

    # Header Styles
    a << {:name => 'asset_id_col', :bg_color => "EBF1DE", :fg_color => '000000', :b => false, :alignment => { :horizontal => :center }}

    a << {:name => 'maintenance_type_locked', :bg_color => "b0d6f1", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'mileage_locked', :num_fmt => 3, :bg_color => "b0d6f1", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'maintenance_date_locked', :format_code => 'MM/DD/YYYY', :bg_color => "b0d6f1", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'maintenance_type', :bg_color => "b0d6f1", :alignment => { :horizontal => :center } , :locked => false }
    a << {:name => 'mileage', :num_fmt => 3, :bg_color => "b0d6f1", :alignment => { :horizontal => :center } , :locked => false }
    a << {:name => 'maintenance_date', :format_code => 'MM/DD/YYYY', :bg_color => "b0d6f1", :alignment => { :horizontal => :center } , :locked => false }
    a << {:name => 'maintenance_notes', :bg_color => "b0d6f1", :alignment => { :horizontal => :left } , :locked => false}

    a.flatten
  end

  def worksheet_name
    'Updates'
  end

  private

  def initialize(*args)
    super
    @search_parameter = Rails.application.config.asset_seed_class_name.constantize.find_by(id: @search_parameter_value)
  end

  def include_mileage_columns?

    if @search_parameter.class_name.include? "Vehicle"
      true
    else
      false
    end
  end

end
