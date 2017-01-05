class AddDelayedJobPriorities < ActiveRecord::Migration
  def change
    create_table :delayed_job_priorities do |t|
      t.string :class_name,     null: false
      t.integer :priority,      null: false, default: 0

      t.timestamps
    end
  end
end
