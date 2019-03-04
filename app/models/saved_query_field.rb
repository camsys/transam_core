class SavedQueryField < ApplicationRecord
  belongs_to :saved_query
  belongs_to :query_field
end
