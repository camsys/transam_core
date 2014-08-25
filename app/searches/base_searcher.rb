#
# Abstract base searcher class for searches
#
class BaseSearcher

  # From the application config    
  MAX_ROWS_RETURNED         = SystemConfig.instance.max_rows_returned
  
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
  
  # Override this to return the name of the results table to display
  def results_view
  end

  def to_s
    conditions
  end

  protected

  # returns a list of PKs from a collection
  def get_id_list(coll)
    ids = []
    coll.each do |e|
      ids << e.id
    end
    ids
  end
  
  # requires each attribute in the hash to be names the same as the class property
  def mass_assign(attributes)
    attributes.each do |attribute, value|
      respond_to?(:"#{attribute}=") && send(:"#{attribute}=", value)
    end
  end   

  # These methods scan the class and assemble a set of conditions and parameters
  # that can be used to query the database
  def conditions
    [conditions_clauses.join(' AND '), *conditions_options]
  end
  
  def conditions_clauses
    conditions_parts.map { |condition| condition.first }
  end
  
  def conditions_options
    conditions_parts.map { |condition| condition[1..-1] }.flatten(1)
  end
  
  def conditions_parts
    private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
  end    
       
end
