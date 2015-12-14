#------------------------------------------------------------------------------
#
# InventoryUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing inventory
#
#------------------------------------------------------------------------------
class InventoryUpdatesTemplateBuilder < TemplateBuilder

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)
    @asset_types.each do |asset_type|
      assets = @organization.assets.operational.where('asset_type_id = ?', asset_type)
      assets.each do |a|
        asset = Asset.get_typed_asset(a)
        row_data  = []
        row_data << asset.object_key
        row_data << asset.asset_type.name
        row_data << asset.asset_subtype.name
        row_data << asset.asset_tag
        row_data << asset.external_id
        row_data << asset.description

        row_data << (asset.service_status_type || "-") # prev_service_status
        row_data << (asset.service_status_date || "-") # prev_service_status date
        row_data << nil # current_service_status
        row_data << nil # date

        row_data << asset.reported_condition_rating # Previous Condition
        row_data << asset.reported_condition_date # Previous Condition
        row_data << nil # Current Condition
        row_data << nil # Date

        sheet.add_row row_data, :types => row_types
      end
    end
    # Do nothing
  end

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)

    # Add a lookup table worksheet and add the lookuptable values we need to it
    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    sheet.sheet_protection.password = 'transam'

    row = []
    @service_types = ServiceStatusType.active.pluck(:name)
    @service_types.each do |x|
      row << x unless x.eql? "Unknown"
    end
    sheet.add_row row

  end

  # Performing post-processing
  def post_process(sheet)

    # Merge Cells?
    sheet.merge_cells("A1:F1")
    sheet.merge_cells("G1:J1")
    sheet.merge_cells("K1:N1")

    # This is used to get the column name of a lookup table based on its length
    alphabet = ('A'..'Z').to_a
    earliest_date = SystemConfig.instance.epoch

    # Service Status
    sheet.add_data_validation("I3:I1000", {
      :type => :list,
      :formula1 => "lists!$A$1:$#{alphabet[@service_types.size]}$1",
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Service type',
      :prompt => 'Only values in the list are allowed'})

    # Service Status Date
    sheet.add_data_validation("J3:J1000", {
      :type => :time,
      :operator => :greaterThan,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Status Reporting Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    # Condition Rating > 1 - 5, real number
    sheet.add_data_validation("M2:M1000", {
      :type => :decimal,
      :operator => :between,
      :formula1 => '1.0',
      :formula2 => '5.0',
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Rating value must be between 1 and 5',
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Condition Rating',
      :prompt => 'Only values between 1 and 5'})

    # Condition date
    sheet.add_data_validation("N2:N1000", {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Reporting Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

  end

  # header rows
  def header_rows
    [
      [
        'Asset',
        '',
        '',
        '',
        '',
        '',
        'Service Status Report',
        '',
        '',
        '',
        'Condition Report',
        '',
        '',
        ''
      ],
      [
        'Id',
        'Class',
        'Subtype',
        'Tag',
        'External Id',
        'Description',

        # Status Report Columns
        'Current Status',
        'Reporting Date',
        'New Status',
        'Reporting Date',

        # Condition Report Columns
        'Current Condition',
        'Reporting Date',
        'New Condition',
        'Reporting Date'
      ]
    ]
  end

  def column_styles
    [
      {:name => 'asset_id_col', :column => 0},
      {:name => 'asset_id_col', :column => 1},
      {:name => 'asset_id_col', :column => 2},
      {:name => 'asset_id_col', :column => 3},
      {:name => 'asset_id_col', :column => 4},
      {:name => 'asset_id_col', :column => 5},

      {:name => 'service_status_string_locked', :column => 6},
      {:name => 'service_status_date_locked',   :column => 7},
      {:name => 'service_status_string',        :column => 8},
      {:name => 'service_status_date',          :column => 9},

      {:name => 'condition_float_locked', :column => 10},
      {:name => 'condition_date_locked',  :column => 11},
      {:name => 'condition_float',        :column => 12},
      {:name => 'condition_date',         :column => 13}
    ]
  end

  def row_types
    [
      # Asset Id Block
      :string,
      :string,
      :string,
      :string,
      :string,
      :string,

      # Service Status Report Block
      :string,
      :date,
      :string,
      :date,

      # Condition Report Block
      :float,
      :date,
      :float,
      :date
    ]
  end
  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super

    # Header Styles
    a << {:name => 'asset_id_col', :bg_color => "EBF1DE", :fg_color => '000000', :b => false, :alignment => { :horizontal => :left }}

    a << {:name => 'service_status_string_locked', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'service_status_date_locked', :format_code => 'MM/DD/YYYY', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'service_status_string', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => false }
    a << {:name => 'service_status_date', :format_code => 'MM/DD/YYYY', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => false }

    a << {:name => 'condition_float_locked', :num_fmt => 2, :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'condition_date_locked', :format_code => 'MM/DD/YYYY', :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'condition_float', :num_fmt => 2, :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => false }
    a << {:name => 'condition_date', :format_code => 'MM/DD/YYYY', :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => false }

    a.flatten
  end

  def worksheet_name
    'Updates'
  end

  private

  def initialize(*args)
    super
  end

end
