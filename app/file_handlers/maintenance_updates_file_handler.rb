#------------------------------------------------------------------------------
#
# MaintenanceUpdatesFileHandler
#
# Generic class for processing maintenance updates for assets from a spreadsheet.
#
# This processes a file that has been exported as a template from the TransAM
# application
#
#------------------------------------------------------------------------------
class MaintenanceUpdatesFileHandler < AbstractFileHandler

  OBJECT_KEY_COL = 0
  ASSET_TAG_COL = 2

  NUM_HEADER_ROWS = 2
  SHEET_NAME = "Updates"

  # Perform the processing
  def process(upload)

    @num_rows_processed = 0
    @num_rows_added = 0
    @num_rows_skipped = 0
    @num_rows_replaced = 0
    @num_rows_failed = 0

    # Get the pertinent info from the upload record
    file_url = upload.file.url                # Usually stored on S3
    organization = upload.organization        # Organization who owns the assets
    system_user = User.find(1)                # System user is always the first user

    add_processing_message(1, 'success', "Updating asset maintenance history from '#{upload.original_filename}'")
    add_processing_message(1, 'success', "Start time = '#{Time.now}'")

    # Open the spreadsheet and start to process the asset events
    begin

      reader = SpreadsheetReader.new(file_url)
      reader.open(SHEET_NAME)

      Rails.logger.info "  File Opened."
      Rails.logger.info "  Num Rows = #{reader.num_rows}, Num Cols = #{reader.num_cols}, Num Header Rows = #{NUM_HEADER_ROWS}"

      # Process each row
      count_blank_rows = 0
      first_row = NUM_HEADER_ROWS + 1
      first_row.upto(reader.last_row) do |row|
        # Read the next row from the spreadsheet
        cells = reader.read(row)
        if reader.empty_row?
          count_blank_rows += 1
          if count_blank_rows > 10
            break
          end
        else
          notes = []
          count_blank_rows = 0
          @num_rows_processed += 1

          # Get the asset by the object key
          object_key = cells[OBJECT_KEY_COL].to_s
          # asset tags are sometimes stored as numbers
          asset_tag   = cells[ASSET_TAG_COL].to_s

          Rails.logger.debug "  Processing row #{row}. Asset ID = '#{object_key}', Asset Tag = '#{asset_tag}'"
          if object_key.present?
            asset = Rails.application.config.asset_base_class_name.constantize.find_by(organization_id: organization.id, object_key: object_key)
          else
            assets = Rails.application.config.asset_base_class_name.constantize.where(asset_tag: asset_tag)
            if assets.count == 1
              asset = assets.first
            end
          end

          # Attempt to find the asset
          # complain if we cant find it
          if asset.nil?
            add_processing_message(2, 'warning', "Could not retrieve asset with ID '#{object_key}'.")
            @num_rows_failed += 1
            next
          else
            add_processing_message(1, 'success', "Processing row[#{row}]  Asset ID: '#{asset_tag}' (#{object_key})")
          end

          # Make sure this row has data otherwise skip it
          idx = -3 # always assume last 3 cells, sometimes 4 with mileage but 3 always includes
          if reader.empty?(cells.length+idx,cells.length-1)
            @num_rows_skipped += 1
            add_processing_message(2, 'info', "No data for row. Skipping.")
            next
          end

          # If all the validations have passed, type the asset
          asset = Rails.application.config.asset_base_class_name.constantize.get_typed_asset(asset)

          if asset.class.to_s.include? 'Vehicle'
            idx = -4
          end

          #---------------------------------------------------------------------
          # Maintenance Update
          #---------------------------------------------------------------------
          add_processing_message(2, 'success', 'Processing Maintenance Report')
          loader = MaintenanceUpdatesEventLoader.new
          loader.process(asset, cells[idx..-1])
          if loader.errors?
            row_errored = true
            loader.errors.each { |e| add_processing_message(3, 'warning', e)}
          end
          if loader.warnings?
            loader.warnings.each { |e| add_processing_message(3, 'info', e)}
          end

          # Check for any validation errors
          event = loader.event
          if event.valid?
            event.upload = upload
            event.save
            add_processing_message(3, 'success', 'Maintenance history updated.')
            Delayed::Job.enqueue AssetMaintenanceUpdateJob.new(asset.object_key), :priority => 10
          else
            Rails.logger.info "Maintenance record did not pass validation."
            event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
          end
        end
      end

      @new_status = FileStatusType.find_by_name("Complete")
    rescue => e
      Rails.logger.warn "Exception caught: #{e.backtrace.join("\n")}"
      @new_status = FileStatusType.find_by_name("Errored")
      raise e
    ensure
      reader.close unless reader.nil?
    end

    add_processing_message(1, 'success', "Processing Completed at  = '#{Time.now}'")

  end

  # Init
  def initialize(upload)
    super
    @upload = upload
  end

  def included_serial_number?(asset)
    asset.type_of? :vehicle or asset.type_of? :support_vehicle or asset.type_of? :equipment
  end

end
