class QueryField < ApplicationRecord
  has_many :query_field_asset_classes, dependent: :destroy
  has_many :query_asset_classes, through: :query_field_asset_classes
  has_many :query_filters, dependent: :destroy
  belongs_to :query_association_class
  belongs_to :query_category

  scope :auto_show, -> { where(auto_show: true) }
  scope :visible, -> { where(hidden: [nil, false]) }
  scope :by_category_id, -> (category_id) { where(query_category_id: category_id) }

  # Get Multi-Select Values
  def multi_select_options
    # TODO: Here is a list of query field special cases that need to be handled.
    # 37: fta_type_type_id
    # 149: infrastructure_division_id
    # 150: infrastructure_subdivision_id
    # 151: infrastructure_track_id
    # 153: direction
    # 197: land_ownership_organization_id
    # 212: sourceable_id
    # 220: categorization_name
    # 222: period
    # 234: operational_service_status

    model_values =  []
    unless query_association_class.nil?
      association_model = query_association_class.table_name.classify.constantize rescue nil
      return model_values if association_model.nil?
      if association_model.respond_to? :active
        model_values = association_model.active
      else
        model_values = association_model.all
      end

      model_values = model_values.pluck(query_association_class.id_field_name, query_association_class.display_field_name).map{ |mv| {id: mv.first, name: mv.last} }
    end

    return model_values
  end

  def as_json(options = {})
    resp = super options
    if options[:get_multi_select_options]
      resp[:multi_select_options] = multi_select_options
    end
    return resp 
  end
end
