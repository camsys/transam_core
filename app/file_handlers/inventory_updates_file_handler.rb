#------------------------------------------------------------------------------
#
# InventoryUpdatesFileHandler
#
# Generic class for processing inventory updates for assets from a spreadsheet.
#
# This processes a file that has been exported as a template from the TransAM
# application
#
#------------------------------------------------------------------------------
class InventoryUpdatesFileHandler < AbstractFileHandler

  OBJECT_KEY_COL = 0
  ASSET_SUBTYPE_COL = 2
  ASSET_TAG_COL = 3

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

    add_processing_message(1, 'success', "Updating asset status from '#{upload.original_filename}'")
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
          subtype_str = cells[ASSET_SUBTYPE_COL].to_s
          # asset tags are sometimes stored as numbers
          asset_tag   = cells[ASSET_TAG_COL].to_s

          Rails.logger.debug "  Processing row #{row}. Asset ID = '#{object_key}', Subtype = '#{subtype_str}', Asset Tag = '#{asset_tag}'"
          asset = Asset.find_by('organization_id = ? AND object_key = ?', organization.id, object_key)

          # Attempt to find the asset
          # complain if we cant find it
          if asset.nil?
            add_processing_message(2, 'warning', "Could not retrieve asset with ID '#{object_key}'.")
            @num_rows_failed += 1
            next
          else
            add_processing_message(1, 'success', "Processing row[#{row}]  Asset ID: '#{object_key}', Subtype: '#{subtype_str}', Asset Tag: '#{asset_tag}'")
          end

          #### Validations on Asset ####
          # Check to see if this asset tag and subtype are the same
          unless asset.asset_subtype.name == subtype_str
            add_processing_message(2, 'warning', "Mismatch on asset subtype. Found subtype '#{subtype_str}' expected '#{asset.asset_subtype.name}'. Skipping row.")
            @num_rows_failed += 1
            next
          end

          # Make sure this row has data otherwise skip it
          if reader.empty?(8,8) and reader.empty?(12,12) and reader.empty?(16,16)
            @num_rows_skipped += 1
            add_processing_message(2, 'info', "No data for row. Skipping.")
            next
          end

          has_new_event = false

          # If all the validations have passed, type the asset
          asset = Asset.get_typed_asset(asset)

          #---------------------------------------------------------------------
          # Service Status
          #---------------------------------------------------------------------
          unless reader.empty?(8, 8)
            add_processing_message(2, 'success', 'Processing Service Status Report')
            loader = ServiceStatusUpdateEventLoader.new
            loader.process(asset, cells[8..9])
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
              event.creator = upload.user
              event.updater = upload.user
              event.save
              add_processing_message(3, 'success', 'Service Status updated.')
              has_new_event = true
            else
              Rails.logger.info "Service Status did not pass validation."
              event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
            end
          end

          #---------------------------------------------------------------------
          # Condition
          #---------------------------------------------------------------------
          unless reader.empty?(12, 12)
            add_processing_message(2, 'success', 'Processing Condition Report')
            loader = ConditionUpdateEventLoader.new
            loader.process(asset, cells[12..13])
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
              event.creator = upload.user
              event.updater = upload.user
              event.save
              add_processing_message(3, 'success', 'Condition Update added.')
              has_new_event = true
            else
              Rails.logger.info "Condition Update did not pass validation."
              event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
            end
          end

          #---------------------------------------------------------------------
          # Fire update events for the asset if a new event was added
          #---------------------------------------------------------------------
          if has_new_event
            @num_rows_added += 1
            #Delayed::Job.enqueue AssetUpdateJob.new(asset.object_key), :priority => 10, :run_at => 30.seconds.from_now
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

end
