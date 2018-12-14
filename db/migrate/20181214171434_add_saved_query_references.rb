class AddSavedQueryReferences < ActiveRecord::Migration[5.2]
  def change
    add_reference :query_filters, :saved_query_id, index: true
  end
end
