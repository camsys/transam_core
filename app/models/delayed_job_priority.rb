#-------------------------------------------------------------------------------
#
# DelayedJobPriority
#
# Configure priority for each job class.
#
#-------------------------------------------------------------------------------
class DelayedJobPriority < ActiveRecord::Base
  after_initialize  :set_defaults

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :class_name,              :presence => true, :uniqueness => true
  validates :priority,                :presence => true, numericality: { only_integer: true }

  private

  def set_defaults
    self.priority = 0 unless self.priority.present?
  end
end