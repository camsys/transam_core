class RemoveDefaultFromDelayedJobPriorities < ActiveRecord::Migration[5.2]
  def change
    change_column_default :delayed_job_priorities, :priority, nil
  end
end
