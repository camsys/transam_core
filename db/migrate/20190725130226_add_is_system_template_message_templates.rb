class AddIsSystemTemplateMessageTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :message_templates, :is_system_template, :boolean, after: :email_enabled
    add_column :message_templates, :message_enabled, :boolean, after: :active
    add_column :message_templates, :is_implemented, :boolean, after: :is_system_template
  end
end
