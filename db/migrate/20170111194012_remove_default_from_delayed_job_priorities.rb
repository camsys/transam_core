class RemoveDefaultFromDelayedJobPriorities < ActiveRecord::Migration
  def change
    change_column_default :delayed_job_priorities, :priority, nil
  end
end
