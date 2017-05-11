# Validates that engine seed data has loaded as expected
# Added to a dynamically generated validate_seeds_data.rb file
# Via the transam_{engine_name}:validate_engine_seeds rake task
# Which should only be called from an app-level validate_engine_seeds rake task

# Initialize the standard table name arrays in case they were never created
lookup_tables ||= []
replace_tables ||= []
merge_tables ||= []

# Validate rows from tables mentioned in the standard table name arrays
%w{lookup_tables replace_tables merge_tables}.each do |table_name_array_name|

  puts "    Validating #{table_name_array_name}"
  table_name_array = eval(table_name_array_name)
  table_name_array.each do |table_name|
    puts "      #{table_name}"
    data = eval(table_name)
    klass = table_name.classify.constantize
    data.each.with_index do |row, i|
      row_does_not_exist = klass.find_by(row).nil?
      row_is_not_unique = klass.where(row).count > 1

      puts "        #{row.inspect} does not exist in this environment." if row_does_not_exist
      puts "        #{row.inspect} is not unique in this environment." if row_is_not_unique

      # Skip this check with merge_tables, where id will vary
      unless table_name_array_name == "merge_tables"
        row_has_an_unexpected_id = false
        unless row_does_not_exist || row_is_not_unique
          row_has_an_unexpected_id = klass.find_by(row).id != i + 1
        end

        puts "        #{row.inspect} has an unexpected id in this environment. Got #{klass.find_by(row).id}. Expected #{i + 1}." if row_has_an_unexpected_id
      end
    end
  end

end

# Validate specially handled tables (like reports)
# NOTE: this will need to be updated by hand if we add tables or change logic

puts "    Validating specially handled tables"

puts "      reports"
reports.each.with_index do |row, i|
  filtered_row = row.except(:belongs_to, :type)
  filtered_row[:report_type] = ReportType.where(:name => row[:type]).first
  row_does_not_exist = Report.find_by(filtered_row).nil?
  row_is_not_unique = Report.where(filtered_row).count > 1
  report_type_not_found = filtered_row[:report_type].nil?

  row_has_an_unexpected_id = false
  unless row_does_not_exist || row_is_not_unique
    row_has_an_unexpected_id = Report.find_by(filtered_row).id != i + 1
  end

  puts "        #{row.inspect} does not exist in this environment." if row_does_not_exist
  puts "        #{row.inspect} is not unique in this environment." if row_is_not_unique
  puts "        #{row.inspect} does not associate with a report_type in this environment. Searched ReportType by name, using: #{row[:type]}." if report_type_not_found
  puts "        #{row.inspect} has an unexpected id in this environment. Got #{Report.find_by(filtered_row).id}. Expected #{i + 1}." if row_has_an_unexpected_id
end

puts "      asset_subsystems"
asset_subsystems.each.with_index do |row, i|
  asset_type = AssetType.find_by(name: [:asset_type])
  row[:asset_type] = asset_type

  row_does_not_exist = AssetSubsystem.find_by(row).nil?
  row_is_not_unique = AssetSubsystem.where(row).count > 1
  asset_type_not_found = row[:asset_type].nil?

  row_has_an_unexpected_id = false
  unless row_does_not_exist || row_is_not_unique
    row_has_an_unexpected_id = AssetSubsystem.find_by(row).id != i + 1
  end

  puts "        #{row.inspect} does not exist in this environment." if row_does_not_exist
  puts "        #{row.inspect} is not unique in this environment." if row_is_not_unique
  puts "        #{row.inspect} does not associate with an asset_type in this environment. Searched AssetType by name, using: #{:asset_type}." if asset_type_not_found
  puts "        #{row.inspect} has an unexpected id in this environment. Got #{AssetSubsystem.find_by(row).id}. Expected #{i + 1}." if row_has_an_unexpected_id
end
