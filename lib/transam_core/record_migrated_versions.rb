module TransamCore
  class Engine < ::Rails::Engine
    initializer :record_migrated_versions do |app|
      # Overrides record_version_state_after_migrating so it also writes to a migrated versions file
      # This file becomes the source for the schema_migrations table after a db:schema:load
      # This is more reliable than assuming that migrations up to the current schema version have been run

      # Note: the migrated versions file changes with the schema
      # It should be committed or not committed alongside it
      ActiveRecord::Migrator.class_eval do
        def record_version_state_after_migrating(version)

          # Location of the migrated versions file in the app (or dummy app) that includes this engine
          # Access to this info is why we wrapped our override in an initializer
          migrated_versions_file = Rails.root.join('db', 'migrated_versions.txt').to_s

          if down?
            migrated.delete(version)
            ActiveRecord::SchemaMigration.where(:version => version.to_s).delete_all

            # Checks if a migrated versions file exists
            # Only deviates from the default behavior if it does
            # Rewrites the migrated versions file without the deleted version
            if File.exist?(migrated_versions_file)
              migrated_versions = ""

              File.open(migrated_versions_file, "r") do |f|
                f.each_line do |line|
                  migrated_versions += line unless line.strip == version.to_s
                end
              end

              File.open(migrated_versions_file, "w") do |f|
                f.write(migrated_versions)
              end

              puts "== #{version} removed from #{migrated_versions_file}\n\n"
            end
          else
            migrated << version
            ActiveRecord::SchemaMigration.create!(:version => version.to_s)

            # Checks if a migrated versions file exists
            # Only deviates from the default behavior if it does
            # Appends the added version to the end of the migrated versions file
            if File.exist?(migrated_versions_file)
              migrated_version_present = false

              File.open(migrated_versions_file, "r") do |f|
                f.each_line do |line|
                  if line.strip == version.to_s
                    migrated_version_present = true
                    break
                  end
                end
              end

              unless migrated_version_present
                File.open(migrated_versions_file, "a") do |f|
                  f.write("#{version}\n")
                end

                puts "== #{version} added to #{migrated_versions_file}\n\n"
              end
            end
          end

        end # End of method

      end # End of class_eval
    end # End of initializer
  end # End of Engine class
end # End of TransamCore module
