class AddMessageTemplateReferenceToMessage < ActiveRecord::Migration[5.2]
  def change
    add_reference :messages, :message_template, index: true
  end
end
