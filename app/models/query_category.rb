class QueryCategory < ApplicationRecord
  has_many :query_fields, dependent: :destroy
end
