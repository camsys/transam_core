# Inventory searcher.
# Designed to be populated from a search form using a new/create controller model.
#
class AssetMapSearcher < BaseSearcher
  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers

  attr_accessor :asset_seed_class_name

  # Return the name of the form to display
  def form_view
    'asset_search_form'
  end
  # Return the name of the results table to display
  def results_view
    'asset_search_results_table'
  end

  def initialize(attributes = {})
    super(attributes)

    set_seed_class
  end

  def set_seed_class
    if asset_seed_class_name.present?
      @klass = Object.const_get asset_seed_class_name
    else
      @klass = Object.const_get Rails.application.config.asset_base_class_name
    end
  end

  def to_s
    queries(false).to_sql
  end

  def asset_type_class_name
    @klass.to_s
  end

  def cache_variable_name
    AssetsController::INDEX_KEY_LIST_VAR
  end

  def cache_params_variable_name
    "asset_query_search_params_var"
  end

  def default_sort
    'asset_tag'
  end

  private

  def remove_blanks(input)
    output = (input.is_a?(Array) ? input : [input])
    output.select { |e| !e.blank? }
  end

end
