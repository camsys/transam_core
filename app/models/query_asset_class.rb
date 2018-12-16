class QueryAssetClass < ApplicationRecord
  has_many :query_field_asset_classes
  has_many :query_fields, through: :query_field_asset_classes

  validates :table_name, presence: true, uniqueness: true
end
