class AddDisplayFieldToQueryFields < ActiveRecord::Migration[5.2]
  def change
    add_column :query_fields, :display_field, :string
  end
end
