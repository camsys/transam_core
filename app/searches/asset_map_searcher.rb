# Inventory searcher.
# Designed to be populated from a search form using a new/create controller model.
#
class AssetMapSearcher < BaseSearcher

  attr_accessor :asset_seed_class_name

  SystemConfig.transam_module_names.each do |mod|
    if eval("defined?(#{mod.titleize}AssetMapSearcher) && #{mod.titleize}AssetMapSearcher.is_a?(Class)") == true
      "#{mod.titleize}AssetMapSearcher".constantize.form_params.each do |form_param|
        attr_accessor form_param
      end
    end
  end

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

  protected

  #
  # Override BaseSearcher method so can iterate through different engine searcher sub-classes
  #
  # Finds each method named *_conditions and runs it in the concrete class
  # Returns an array of ActiveRecord::Relation objects
  def condition_parts(with_orgs=true)
    ### Subclass MUST respond with at least 1 non-nil AR::Relation object  ###

    conditions = []

    SystemConfig.transam_module_names.each do |mod|
      conditions += "#{mod.titleize}AssetMapSearcher".constantize.new.private_methods.grep(/_conditions$/) rescue nil
    end

    unless with_orgs
      conditions = conditions - [:organization_conditions]
    end

    conditions.map { |m| send(m) }.compact
  end

  private

end
