class FixFullTextSearchIndices < ActiveRecord::Migration

  def change
    drop_table :keyword_search_indices
  end

end
