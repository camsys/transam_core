class ModifyTasks < ActiveRecord::Migration
  def change
    # Modifications to the tasks table to suport modification to Taskable
    rename_column :tasks, :from_user_id,            :user_id
    rename_column :tasks, :for_organization_id,     :organization_id

    remove_column :tasks, :from_organization_id
    remove_column :tasks, :task_status_type_id
    remove_column :tasks, :completed_on

    add_column    :tasks, :taskable_id,     :integer,                 :after => :object_key
    add_column    :tasks, :taskable_type,   :string,  :limit => 255,  :after => :taskable_id
    add_column    :tasks, :state,           :string,  :limit => 32,   :after => :send_reminder

    # Index the state
    add_index     :tasks, :state, :name => :tasks_idx3
    # Ger rid of the task status types tables
    drop_table    :task_status_types
  end
end
