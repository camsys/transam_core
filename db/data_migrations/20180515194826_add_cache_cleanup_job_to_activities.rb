class AddCacheCleanupJobToActivities < ActiveRecord::DataMigration
  def up
    Activity.create!(
        {:name => 'Session Cleanup', :description => 'Session cleanup job every 15 mins.', :job_name => 'SessionCacheCleanupJob', :frequency_quantity => 15, :frequency_type_id => 2, :execution_time => '**:15', :show_in_dashboard => false, :active => true}
    )
  end
end