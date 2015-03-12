class PriorityType < ActiveRecord::Base

  #attr_accessible :name, :description, :active, :default

  # default scope
  default_scope { where(:active => true) }

  def self.default
    find_by(:is_default => true)
  end

  def to_s
    name
  end

end
