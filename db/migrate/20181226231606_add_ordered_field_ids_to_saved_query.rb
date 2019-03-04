class AddOrderedFieldIdsToSavedQuery < ActiveRecord::Migration[5.2]
  def change
    add_column :saved_queries, :ordered_output_field_ids, :text
  end
end
