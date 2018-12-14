class QueryField < ApplicationRecord
  has_many :query_field_asset_classes
  has_many :query_asset_classes, through: :query_field_asset_classes
end
