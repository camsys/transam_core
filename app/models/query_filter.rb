class QueryFilter < ApplicationRecord
  belongs_to :query_field
  belongs_to :saved_query
end
