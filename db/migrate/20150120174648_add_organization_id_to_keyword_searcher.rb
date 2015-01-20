class AddOrganizationIdToKeywordSearcher < ActiveRecord::Migration
  def change
    add_column    :keyword_search_indices, :organization_id, :integer, :null => false, :after => :object_key
  end
end
