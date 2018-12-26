class QueryAssetClass < ApplicationRecord
  has_many :query_field_asset_classes, dependent: :destroy
  has_many :query_fields, through: :query_field_asset_classes

  validates :table_name, presence: true, uniqueness: true
end
