#------------------------------------------------------------------------------
#
# TemplateBuilder
#
# Base class for template builders
#
#------------------------------------------------------------------------------
class TemplateBuilder

  attr_accessor :organization
  attr_accessor :asset_types

  def build

    # Create a new workbook
    p = Axlsx::Package.new
    wb = p.workbook

    # Add the worksheet
    sheet = wb.add_worksheet(:name => worksheet_name)

    # setup any styles and cache them for later
    style_cache = {}
    styles.each do |s|
      puts s.inspect
      style = wb.styles.add_style(s)
      puts style.inspect
      style_cache[s[:name]] = style
    end
    puts style_cache.inspect

    # Add the header rows
    header_rows.each do |header_row|
      sheet.add_row header_row
    end

    # Add the column styles
    column_styles.each do |col_style|
      puts col_style.inspect
      sheet.col_style col_style[:column], style_cache[col_style[:name]]
    end

    # add the rows
    add_rows(sheet)

    sheet.merge_cells("A1:B1")

    # Serialize the spreadsheet to the stream and return it
    p.to_stream()

  end


  protected

  # Override with new styles
  def styles
    [
      {:name => 'asset_id_col',  :num_fmt => 0, :bg_color => "FFBDC8", :fg_color => '000000', :b => true},
      {:name => 'general',  :num_fmt => 0},
      {:name => 'currency', :num_fmt => 5},
      {:name => 'percent',  :num_fmt => 9},
      {:name => 'date',     :format_code => "yyyy-mm-dd"},
      {:name => 'vehichle_characteristic', :num_fmt => 0, :bg_color => "FFFEB2", :b => true}
    ]
  end

  # Override this to add column styles
  def column_styles
    # [
    #   {:name => 'general', :column => 0},
    #   {:name => 'general', :column => 1},
    #   {:name => 'general', :column => 2}
    #]
    []
  end

  # Override this to provide the worksheet name
  def worksheet_name
    'default'
  end
  # Override this to get the header rows
  def header_rows
    [
      ['COL_1', 'COL_2', 'COL_3']
    ]
  end
  # Override this at rows to the sheet
  def add_rows(sheet)
    # Do nothing
  end

  private

  def initialize(*args)

  end

end
