class CreateMessageTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :message_templates do |t|
      t.references :priority_type, index: true
      t.string :object_key
      t.string :name
      t.string :subject
      t.text :description
      t.text :delivery_rules
      t.text :body
      t.boolean :active
      t.boolean :email_enabled

      t.timestamps
    end
  end
end
