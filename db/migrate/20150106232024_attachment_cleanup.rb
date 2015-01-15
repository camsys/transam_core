class AttachmentCleanup < ActiveRecord::Migration
  def change
    # Drop Attachments and Attachment Types tables
    drop_table :attachments if table_exists? :attachments
    drop_table :attachment_types if table_exists? :attachment_types
  end
end
