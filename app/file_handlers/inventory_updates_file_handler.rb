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
  ASSET_SUBTYPE_COL = 1
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

          Rails.logger.info "  Processing row #{row}. Asset ID = '#{object_key}', Subtype = '#{subtype_str}', Asset Tag = '#{asset_tag}'"
          asset = Asset.where('organization_id = ? AND object_key = ?', organization.id, object_key).first

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

          # Check to see if this asset tag and subtype are the same
          unless asset.asset_tag == asset_tag
            add_processing_message(2, 'warning', "Mismatch on asset tag. Found tag '#{asset_tag}' expected '#{asset.asset_tag}'. Skipping row.")
            @num_rows_failed += 1
            next
          end

          # Make sure this row has data otherwise skip it
          if reader.empty?(4, 24)
            @num_rows_skipped += 1
            add_processing_message(2, 'info', "No data for row. Skipping.")
            next
          end

          has_new_event = false

          # If all the validations have passed, type the asset
          asset = Asset.get_typed_asset(asset)


          #### Condition Report Block #########################################
          if asset.type_of? :vehicle or asset.type_of? :support_vehicle
            unless reader.empty?(4, 4) # Only Current Mileage field is required
              add_processing_message(2, 'success', 'Processing Mileage Report')
              loader = MileageUpdateEventLoader.new
              loader.process(asset, cells[4..6])
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
                add_processing_message(3, 'success', 'Mileage Update added.')
                has_new_event = true
              else
                Rails.logger.info "Mileage Update did not pass validation."
                event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
              end
            end
          end

          unless reader.empty?(5, 5)
            add_processing_message(2, 'success', 'Processing Condition Report')
            loader = ConditionUpdateEventLoader.new
            loader.process(asset, cells[4..7])
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
              add_processing_message(3, 'success', 'Condition Update added.')
              has_new_event = true
            else
              Rails.logger.info "Condition Update did not pass validation."
              event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
            end
          end


          #### Replacement Report Block########################################
          unless reader.empty?(8, 8)
            add_processing_message(2, 'success', 'Processing Replacement/Rebuild Report')
            loader = ReplacementUpdateEventLoader.new
            loader.process(asset, cells[8..10])
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
              add_processing_message(3, 'success', 'Replacment Update added.')
              has_new_event = true
            else
              Rails.logger.info "Replacement Update did not pass validation."
              event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
            end
          end

          unless reader.empty?(9, 9)
            add_processing_message(2, 'success', 'Processing Rebuild Report')
            loader = RehabilitationUpdateEventLoader.new
            loader.process(asset, cells[8..10])
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
              add_processing_message(3, 'success', 'Rebuild Update added.')
              has_new_event = true
            else
              Rails.logger.info "Rebuild Update did not pass validation."
              event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
            end
          end


          ##### Usage Metrics Report Block ####################################
          unless reader.empty?(11, 16)
            add_processing_message(2, 'success', 'Processing Usage Metrics Report')
            loader = UsageUpdateEventLoader.new
            loader.process(asset, cells[11..16])
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
              add_processing_message(3, 'success', 'Usage Update added.')
              has_new_event = true
            else
              Rails.logger.info "Usage Update did not pass validation."
              event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
            end

            unless reader.empty?(14, 14) # Only Usage Codes field is required
              loader = UsageCodesUpdateEventLoader.new
              loader.process(asset, cells[11..16])
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
                add_processing_message(3, 'success', 'Usage Code Update added.')
                has_new_event = true
              else
                Rails.logger.info "Usage Code Update did not pass validation."
                event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
              end
            end
          end


          #### Operational Metrics Report Block ###############################
          unless reader.empty?(17, 17)
            add_processing_message(2, 'success', 'Processing Maintentance Provider Report')
            loader = MaintenanceProviderUpdateEventLoader.new
            loader.process(asset, cells[17..24])
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
              add_processing_message(3, 'success', 'Maintenance Provider Update added.')
              has_new_event = true
            else
              Rails.logger.info "Maintenance Provider Update did not pass validation."
              event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
            end
          end

          unless reader.empty?(18, 18)
            add_processing_message(2, 'success', 'Processing Storage Method Report')
            loader = StorageMethodUpdateEventLoader.new
            loader.process(asset, cells[17..24])
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
              add_processing_message(3, 'success', 'Storage Method Update added.')
              has_new_event = true
            else
              Rails.logger.info "Storage Method Update did not pass validation."
              event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
            end
          end

          unless reader.empty?(19, 22)
            add_processing_message(2, 'success', 'Processing Operational Metrics Report')
            loader = OperationsUpdateEventLoader.new
            loader.process(asset, cells[17..24])
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
              add_processing_message(3, 'success', 'Operations Update added.')
              has_new_event = true
            else
              Rails.logger.info "Operations Update did not pass validation."
              event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
            end
          end

          # Fire update events for the asset if a new event was added
          if has_new_event
            @num_rows_added += 1
            Delayed::Job.enqueue AssetUpdateJob.new(asset.object_key), :priority => 10, :run_at => 30.seconds.from_now
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
