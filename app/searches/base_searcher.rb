#
# Abstract base searcher class for searches
#
class BaseSearcher

  # Every search must have a user as the searcher
  attr_accessor :user

  #performs ActiveRecord-like mass assignment of attributes
  def initialize(attributes = {})
    mass_assign(attributes)
  end

  # Caches the rows
  def data
    @data ||= perform_query
  end

  # Override this to return the name of the form to display
  def form_view
  end

  # Override this to return a session cache variable for storing the
  # results set for paging through the result lists
  def cache_variable_name
  end

  # Override this to return use a session cache list for saved results
  def cached_data(list)
    @klass.where(object_key: list) if @klass
  end

  def cache_params_variable_name
    "query_search_params_var"
  end

  # Override this to return the name of the results table to display
  def results_view
  end

  def to_s
    queries.to_sql
  end

  protected

  #############################################################################
  # Creation methods
  #############################################################################

  # requires each attribute in the hash to be names the same as the class property
  def mass_assign(attributes)
    attributes.each do |attribute, value|
      respond_to?(:"#{attribute}=") && send(:"#{attribute}=", value)
    end
  end


  #############################################################################
  # Querying methods
  #############################################################################

  # Log query and prepare it for front-end
  def perform_query
    Rails.logger.info queries.to_sql
    queries
  end

  # Reduce as in map-reduce- merges down array of queries into a single one
  def queries(with_orgs=true)
    condition_parts(with_orgs).reduce(:merge)
  end

  # Finds each method named *_conditions and runs it in the concrete class
  # Returns an array of ActiveRecord::Relation objects
  def condition_parts(with_orgs=true)
    ### Subclass MUST respond with at least 1 non-nil AR::Relation object  ###

    if with_orgs
      conditions = private_methods.grep(/_conditions$/)
    else
      conditions = (private_methods.grep(/_conditions$/) - [:organization_conditions])
    end

    conditions.map { |m| send(m) }.compact
  end

end
