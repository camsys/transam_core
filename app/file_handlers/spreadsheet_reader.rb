#------------------------------------------------------------------------------
#
# SpreadsheetReader
#
# Utility class for reading a spreadsheet. Uses the roo gem to open and read the
# spreadsheet. Assumes that the spreadsheet is accessed via a URI so that files
# stored on AWS S3 can be processed in place
#
#------------------------------------------------------------------------------

class SpreadsheetReader
  
  # Get the ith row as an array of ruby objects
  def read(row_number)

    @row = []
    @row_number = row_number
    if @row_number < @first_row || @row_number > @num_rows
      raise ArgumentError, "Invalid row #{@row_number}. Value must be between = #{@first_row} and #{@num_rows}"
    end
    
    @first_col.upto(@sheet.last_column) do |col|
      @row <<  @sheet.cell(@row_number, col)
    end
    
    @row
  end
  
  # returns true if the row is empty, false otherwise. Note, this just tests the first 10 columns
  def empty_row?
    0.upto(9) do |col|
      unless @row[col].blank?
        return false
      end
    end
    return true
  end
  
  # Check to see if a section of the spreasheet row is empty or not
  def empty?(start_range, stop_range)
    (start_range..stop_range).each do |col|
      unless @row[col].blank?
        return false
      end
    end
    return true
  end
  
  # Open the spreadsheet so the rows can be processed
  def open(sheet_name = default_sheet_name)
    
    Rails.logger.debug "Opening spreadsheet #{@file_url} and setting sheet name to #{sheet_name}."
    @sheet_name = sheet_name
    
    # See what type of spreadsheet we are opening, XLSX or XLS
    file_ext = File.extname(@file_url)
    if file_ext == ".xlsx"
      @sheet = Roo::Excelx.new(@file_url)
    elsif file_ext == ".xls"
      @sheet = Roo::Excel.new(@file_url)      
    else
      # exit with an error if the type is something else
      raise ArgumentError, "Invalid spreadsheet type #{file_ext} for file #{@file_url}. Expected 'xls' or 'xlsx'."
    end
    @sheet.default_sheet = sheet_name
    
    @first_row = @sheet.first_row
    @first_col = @sheet.first_column
    @num_rows  = @sheet.last_row 
    @num_cols  = @sheet.last_column 
    Rails.logger.debug "Spreadsheet opened. values from [#{@first_row}, #{@first_col}] to [#{@sheet.last_row}, #{@sheet.last_column}]"
    
    @row = []
    
  end
  
  def row
    @row
  end
  
  def last_row
    @sheet.last_row unless @sheet.nil?
  end
  
  def num_rows
    @num_rows
  end
  
  def num_cols
    @num_cols
  end
  
  # Close the spreadsheet and release resources
  def close
    @sheet = nil
    @num_rows = 0
    @num_cols = 0
    @first_col = 0
    @last_col = 0
  end
  
  private
  
  def initialize(file_url, default_sheet_name = 'Inventory')
    @file_url = file_url  
    @default_sheet_name = default_sheet_name
  end
  
end