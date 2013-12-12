#
# Abstract base searcher class for searches
#
class BaseSearcher
 
  #performs ActiveRecord-like mass assignment of attributes             
  def initialize(attributes = {})
    mass_assign(attributes)
  end    
  
protected

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
    conditions_parts.map { |condition| condition[1..-1] }.flatten
  end
  
  def conditions_parts
    private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
  end    
       
end
