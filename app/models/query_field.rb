class QueryField < ApplicationRecord
  has_many :query_field_asset_classes, dependent: :destroy
  has_many :query_asset_classes, through: :query_field_asset_classes
  has_many :query_filters, dependent: :destroy
  belongs_to :query_association_class
  belongs_to :query_category

  scope :auto_show, -> { where(auto_show: true) }
  scope :visible, -> { where(hidden: [nil, false]) }
  scope :by_category_id, -> (category_id) { where(query_category_id: category_id) }

  def as_json
    {
      id: id,
      name: name,
      filter_type: filter_type,
      query_category_name: query_category.name,
      query_category_id: query_category_id
    }
  end
end
