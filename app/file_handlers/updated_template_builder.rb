#------------------------------------------------------------------------------
#
# TemplateBuilder
#
# Base class for template builders
#
#------------------------------------------------------------------------------
class UpdatedTemplateBuilder

  EARLIEST_DATE = SystemConfig.instance.epoch

  attr_accessor :organization
  attr_accessor :asset_types
  attr_accessor :assets
  attr_accessor :organization_list

  def build

    # Create a new workbook
    p = Axlsx::Package.new
    wb = p.workbook

    # Call back to setup any implementation specific options needed
    setup_workbook(wb)

    # Add the worksheet
    sheet = wb.add_worksheet(:name => worksheet_name)

    setup_lookup_sheet(wb)

    add_columns(sheet)

    # Add headers
    category_row = []
    header_row = []
    idx = 0
    @header_category_row.each do |key, fields|
      category_row << key
      fields.each do |i|
        unless i == fields[0]
          category_row << ''
        end
        header_row << i

        unless @data_validations[i].empty?
          column_letter = convert_index_to_letter(idx)
          sheet.add_data_validation("#{column_letter}3:#{column_letter}1000", @data_validations[i])
        end
        idx+=1
      end
    end
    sheet.add_row category_row
    sheet.add_row header_row

    # add the rows; must be added before to get column styles
    add_rows(sheet)

    #merge header category row and add column header styles
    start = 0
    @header_category_row.each do |key, fields|
      fields.each_with_index do |val, index|
        sheet.col_style start+index, @column_styles[val]
      end
      sheet.merge_cells("#{convert_index_to_letter(start)}1:#{convert_index_to_letter(start+fields.length-1)}1")
      start += fields.length
    end

    # set column widths
    sheet.column_widths *column_widths

    # Perform any additional processing
    post_process(sheet)

    # Serialize the spreadsheet to the stream and return it
    p.to_stream()

  end

  protected

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)
    @style_cache = {}
    @header_category_row = {}
    @column_styles = {}
    @data_validations = {}
  end

  # Override this to provide lookups
  def setup_lookup_sheet(workbook)
    @lookups = {}
  end

  # Override this to add custom column widths
  # Only allow: nil, or numeric values
  def column_widths
    []
  end

  # Override this to provide the worksheet name
  def worksheet_name
    'default'
  end

  # builder overrides this following this breakdown
  def add_columns(sheet)
    ###### MODIFY THIS SECTION ###############
    # add columns
    #add_column(sheet, column_index, name, col_style, data_validation={})


    ######### END MODIFY THIS SECTION ##############
  end

  def add_column(sheet, name, name_category, col_style, data_validation={}, *other_args)
    # add column to header row
    if @header_category_row[name_category].blank?
      @header_category_row[name_category] = [name]
    else
      @header_category_row[name_category] << name
    end

    # get index
    categories = @header_category_row.keys
    column_index = categories[0..categories.index(name_category)].sum{|c| @header_category_row[c].length}-1

    # add style
    if @style_cache[col_style[:name]].nil?
      @style_cache[col_style[:name]] = sheet.workbook.styles.add_style(col_style)
    end
    @column_styles[name] = @style_cache[col_style[:name]]

    # add data validation
    @data_validations[name] = data_validation

    # set any other variables
    unless other_args.empty?
      (0..other_args.length/2-1).each do |arg_idx|
        instance_variable_set("@#{other_args[arg_idx*2]}", instance_variable_get("@#{other_args[arg_idx*2]}").merge({name => other_args[arg_idx*2+1]}))

      end
    end

  end

  def add_event_column(sheet, event_class, include_latest_event=false, asset_field=nil)


    if include_latest_event and asset_field.present?
      add_column(sheet, asset_field.humanize.capitalize, 'Event Updates', {:name => "event_string", :bg_color => 'F2DCDB', :alignment => { :horizontal => :left }, :locked => false })
      add_column(sheet, 'Event Date', 'Event Updates', {:name => "event_date", :format_code => 'MM/DD/YYYY', :bg_color => 'F2DCDB', :alignment => { :horizontal => :left }, :locked => false })

      #TODO figure out how to get asset event latest values
    end
    # get column label from class name
    event_label = event_class[0..-6].gsub(/(?<=[a-z])(?=[A-Z])/, ' ')

    add_column(sheet, event_label, 'Event Updates', {:name => "event_string", :bg_color => 'F2DCDB', :alignment => { :horizontal => :left }, :locked => false })
    add_column(sheet, 'Reporting Date', 'Event Updates', {:name => "event_date", :format_code => 'MM/DD/YYYY', :bg_color => 'F2DCDB', :alignment => { :horizontal => :left }, :locked => false }, {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => EARLIEST_DATE.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{EARLIEST_DATE.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Purchase Date',
      :prompt => "Date must be after #{EARLIEST_DATE.strftime("%-m/%d/%Y")}"})
  end

  # Override this at rows to the sheet
  def add_rows(sheet)
    # Do nothing
  end

  # Override this to process post processing
  def post_process(sheet)
    # Do nothing
  end

  def convert_index_to_letter(num)
    alphabet = ('A'..'Z').to_a
    if num < 26
      alphabet[num]
    else
      alphabet[num/26-1] + alphabet[num%26]
    end
  end

  def get_lookup_cells(lookup_table_name)
    row = @lookups[lookup_table_name][:row]
    column = convert_index_to_letter(@lookups[lookup_table_name][:count]-1)

    return "$A$#{row}:$#{column}$#{row}"
  end

  private

  def initialize(args = {})
    args.each do |k, v|
      self.send "#{k}=", v
    end
  end

end
