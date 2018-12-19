class QueryField < ApplicationRecord
  serialize :depends_on, Array

  has_many :query_field_asset_classes
  has_many :query_asset_classes, through: :query_field_asset_classes
  belongs_to :query_category

  scope :visible, -> { where(depends_on: nil) }
  scope :by_category_id, -> (category_id) { where(query_category_id: category_id) }
end
