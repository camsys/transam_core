class QueryField < ApplicationRecord
  has_many :query_field_asset_classes, dependent: :destroy
  has_many :query_asset_classes, through: :query_field_asset_classes
  has_many :query_filters, dependent: :destroy
  belongs_to :query_association_class
  belongs_to :query_category

  scope :visible, -> { where(hidden: [nil, false]) }
  scope :by_category_id, -> (category_id) { where(query_category_id: category_id) }
end
