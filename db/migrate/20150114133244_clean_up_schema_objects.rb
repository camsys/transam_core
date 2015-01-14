class CleanUpSchemaObjects < ActiveRecord::Migration
  def change
    drop_table :contact_types if table_exists? :contact_types
    drop_table :task_status_types if table_exists? :task_status_types
    drop_table :attachments if table_exists? :attachments
    drop_table :attachment_types if table_exists? :attachment_types
  end
end
