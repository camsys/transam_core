class AttachmentCleanup < ActiveRecord::Migration
  def change
    # Drop Attachments and Attachment Types tables
    drop_table :attachments
    drop_table :attachment_types
  end
end
