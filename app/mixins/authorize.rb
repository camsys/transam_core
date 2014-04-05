#------------------------------------------------------------------------------
#
# Authorize
#
# Mixin that adds an authorization method to a model
#
#------------------------------------------------------------------------------
module Authorize

  #
  # returns true if the refereing object (usually a user) can perform
  # the given action on the given model, false otherwise
  #
  # Allowable actions are
  #  :create
  #  :read
  #  :update
  #  :delete
  #
  def authorize action, model
   
   # Always deny unkown actions
   unless [:create, :read, :update, :delete].include?(action)
     return false
   end 
   
   # no implementation here so we always return true
   return true
   
  end

end
