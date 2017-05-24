# Overrides db:schema:load to use a migrated versions file to build the schema_migrations table
# This is more reliable than assuming that migrations up to the current schema version have been run

Rake::Task["db:schema:load"].clear

namespace :db do
  namespace :schema do
    desc 'Load a schema.rb file into the database'
    task :load => [:environment, :load_config] do
      ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:ruby, ENV['SCHEMA'])

      migrated_versions_file = Rails.root.join('db', 'migrated_versions.txt').to_s

      # Checks if a migrated versions file exists
      # Only deviates from the default behavior if it does
      if File.exist?(migrated_versions_file)
        puts "== Rebuilding schema_migrations from #{migrated_versions_file}"

        ActiveRecord::SchemaMigration.delete_all

        File.open(migrated_versions_file, "r") do |f|
          f.each_line do |line|
            ActiveRecord::SchemaMigration.create!(:version => line.strip)
          end
        end
      end
    end
  end
end
