class AddEmailStatusToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :email_status, :string
  end
end
