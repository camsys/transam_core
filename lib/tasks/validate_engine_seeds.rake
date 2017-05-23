# Validates that engine seed data has loaded as expected
# Should only be called from an app-level validate_engine_seeds rake task

# Copies engine seed data into a temp file
# Adds the contents of a validation script to the file
# Runs the complete file to print validation results
# Then deletes the file

namespace :transam_core do
  desc "validate engine seeds"
  task :validate_engine_seeds, [:app_root] => [:environment] do |t, args|

    # Skip the task unless certain conditions are met
    puts("  Rake task missing the app_root argument (an absolute path string to the app-level root).") || next unless args[:app_root]
    puts("  No db/seeds.rb file found for this engine.") || next unless File.exist?(File.join(TransamCore::Engine.root, "db", "seeds.rb"))
    puts("  No db/validate_seeds_script.rb file found for this engine.") || next unless File.exist?(File.join(TransamCore::Engine.root, "db", "validate_seeds_script.rb"))

    # Read the full db/seeds.rb file
    seeds_file = File.readlines(File.join(TransamCore::Engine.root, "db", "seeds.rb"))

    # Isolate the data from the creation logic

    # Get table rows
    data_start_line_nums = []
    data_end_line_nums = []
    seeds_file.each.with_index do |line, i|
      data_start_line_nums << i if line =~ /\w+ += +\[/
      data_end_line_nums << i if line =~ / *\] *\n/
    end

    data_line_ranges = []
    data_start_line_nums.each.with_index do |num, i|
      data_line_ranges << (num..data_end_line_nums[i])
    end

    seeds_data = seeds_file.select.with_index do |_line, i|
      data_line_ranges.any? do |range|
        range.include?(i)
      end
    end

    # Replace 1/0 with true/false for boolean fields
    # Needed for apps that use postgresql, which won't convert 1/0 implicitly
    # Will have to be updated by hand
    seeds_data.each do |line|
      line.gsub!(/:?active *(=>|:) *1/, ":active => true")
      line.gsub!(/:?active *(=>|:) *0/, ":active => false")
      line.gsub!(/:?show_in_nav *(=>|:) *1/, ":show_in_nav => true")
      line.gsub!(/:?show_in_nav *(=>|:) *0/, ":show_in_nav => false")
      line.gsub!(/:?show_in_dashboard *(=>|:) *1/, ":show_in_dashboard => true")
      line.gsub!(/:?show_in_dashboard *(=>|:) *0/, ":show_in_dashboard => false")

      line.gsub!(/:?asset_manager *(=>|:) *1/, ":asset_manager => true")
      line.gsub!(/:?asset_manager *(=>|:) *0/, ":asset_manager => false")
      line.gsub!(/:?web_services *(=>|:) *1/, ":web_services => true")
      line.gsub!(/:?web_services *(=>|:) *0/, ":web_services => false")
      line.gsub!(/:?is_default *(=>|:) *1/, ":is_default => true")
      line.gsub!(/:?is_default *(=>|:) *0/, ":is_default => false")
    end

    # Get table names (listed in lookup_tables, replace_tables, merge_tables)
    add_line = false
    seeds_file.each do |line|
      add_line = true if line =~ /\w+_tables += +%w\{/
      seeds_data << line if add_line == true
      add_line = false if line =~ /.*\} *\n/
    end

    # NOTE: this leaves out specially handled tables (like reports)
    # The validate seeds script should deal with these individually

    # Read the full db/validate_seeds_script.rb file
    seeds_script = File.readlines(File.join(TransamCore::Engine.root, "db", "validate_seeds_script.rb"))

    # Create the temp file validate_seeds_data.rb
    File.open("validate_seeds_data.rb", "wb") do |f|

      # Add a line to require the app-level rails environment
      f.write("require \"#{File.join(args[:app_root], "config", "environment.rb")}\"\n")

      # Add the seed data
      seeds_data.each do |line|
        f.write(line)
      end

      # Add the validate seeds script
      seeds_script.each do |line|
        f.write(line)
      end
    end

    # Run the completed validate_seeds_data.rb file, then delete it
    if File.exist?("validate_seeds_data.rb")
      ruby "validate_seeds_data.rb"
      File.delete("validate_seeds_data.rb")
    end
  end
end
