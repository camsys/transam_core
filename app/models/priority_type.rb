class PriorityType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  def self.default
    find_by(:is_default => true)
  end

  def to_s
    name
  end

end
