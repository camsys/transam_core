#-------------------------------------------------------------------------------
#
# DelayedJobPriority
#
# Configure priority for each job class.
#
#-------------------------------------------------------------------------------
class DelayedJobPriority < ActiveRecord::Base
  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :class_name,              :presence => true, :uniqueness => true
  validates :priority,                :presence => true, numericality: { only_integer: true }
end