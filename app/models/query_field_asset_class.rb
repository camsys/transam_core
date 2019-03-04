class QueryFieldAssetClass < ApplicationRecord
  belongs_to :query_field
  belongs_to :query_asset_class
end
