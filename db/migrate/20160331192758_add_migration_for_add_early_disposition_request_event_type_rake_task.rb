class AddMigrationForAddEarlyDispositionRequestEventTypeRakeTask < ActiveRecord::Migration
  def change
    reversible do |change|
      change.up do
        Rake::Task['transam_core_data:add_early_disposition_request_event_type'].invoke
      end
    end
  end
end
