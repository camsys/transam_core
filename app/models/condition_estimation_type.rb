class ConditionEstimationType < ActiveRecord::Base

  # Enable auditing of this model type
  has_paper_trail

  # associations
  has_many :policys

  attr_accessible :name, :description, :class_name, :active
        
  # default scope
  default_scope where(:active => true)
        
end
