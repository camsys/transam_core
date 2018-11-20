#-------------------------------------------------------------------------------
#
# TransitInventoryUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing transit inventory
#
#-------------------------------------------------------------------------------
class InventoryUpdatesTemplateBuilder < TemplateBuilder

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)

    if @assets.nil?
      assets =  @asset_class_name.constantize.operational.where(organization_id: @organization.id).where(Rails.application.config.asset_seed_class_name.foreign_key => @search_parameter.id)
    else
      assets = @assets
    end

    assets.each do |asset|
      row_data = []
      row_data << asset.object_key
      row_data << asset.organization.short_name
      row_data << asset.asset_tag
      row_data << asset.external_id
      row_data << asset.asset_subtype
      row_data << asset.description
      row_data << asset.try(:serial_number)

      row_data << asset.try(:service_status_type).try(:name) #prev_service_status
      row_data << asset.service_status_updates.last.try(:event_date) # prev_service_status date
      row_data << nil # current_service_status
      row_data << nil # date

      row_data << asset.reported_condition_rating.to_s # Previous Condition
      row_data << asset.reported_condition_date # Previous Condition
      row_data << nil # Current Condition
      row_data << nil # Date

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
    @service_types = ServiceStatusType.active.pluck(:name)
    @service_types.each do |x|
      row << x unless x.eql? "Unknown"
    end
    sheet.add_row row

  end

  # Performing post-processing
  def post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    sheet.sheet_protection

    # Merge Cells?
    sheet.merge_cells("A1:H1")
    sheet.merge_cells("I1:L1")
    sheet.merge_cells("M1:P1")

    # This is used to get the column name of a lookup table based on its length
    alphabet = ('A'..'Z').to_a
    earliest_date = SystemConfig.instance.epoch

    # Service Status
    sheet.add_data_validation("K3:K1000", {
        :type => :list,
        :formula1 => "lists!$A$1:$#{alphabet[@service_types.size]}$1",
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Service type',
        :prompt => 'Only values in the list are allowed'})

    # Service Status Date
    sheet.add_data_validation("L3:L1000", {
        :type => :time,
        :operator => :greaterThan,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :allow_blank => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Status Reporting Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    # Condition Rating > 1 - 5, real number
    sheet.add_data_validation("O2:O1000", {
        :type => :decimal,
        :operator => :between,
        :formula1 => '1.0',
        :formula2 => '5.0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Rating value must be between 1 and 5',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Condition Rating',
        :prompt => 'Only values between 1 and 5'})

    # Condition date
    sheet.add_data_validation("P2:P1000", {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Reporting Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})
  end

  # header rows
  def header_rows
    title_row = [
        'Asset','','','','','',
    ]
    title_row << ''

    title_row.concat([
                         '',
                         'Service Status Report',
                         '',
                         '',
                         '',
                         'Condition Report',
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

    detail_row.concat([
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

    ]

    styles << {:name => 'asset_id_col', :column => 7}
    diff = 0

    styles.concat([
                      {:name => 'service_status_string_locked', :column => 8},
                      {:name => 'service_status_date_locked',   :column => 9},
                      {:name => 'service_status_string',        :column => 10},
                      {:name => 'service_status_date',          :column => 11},

                      {:name => 'condition_float_locked', :column => 12},
                      {:name => 'condition_date_locked',  :column => 13},
                      {:name => 'condition_float',        :column => 14},
                      {:name => 'condition_date',         :column => 15}
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
                 ])
    types
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

  def include_mileage_columns?

    if @asset_class_name.include? "Vehicle"
      true
    else
      false
    end
  end


end
