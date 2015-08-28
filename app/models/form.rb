#------------------------------------------------------------------------------
#
# Form
#
# Represents a (usually) multi-page form that an organization needs to complete
# for some regulatory or reporting requirement. Forms are database driven and
# depend on classes to drive the actual data collection process. The Form model
# is similar to Report and simply registers a Form with the database and makes
# it available to users with specific roles.
#
# The Form model is a simple placeholder to different form-specific controllers
#
#------------------------------------------------------------------------------
class Form < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  # Allow selection of active instances
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  # Return an array of role names allowed to access this report
  def role_names
    roles.split(',')
  end

end
