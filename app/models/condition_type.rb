class ConditionType < ActiveRecord::Base

  # Enable auditing of this model type
  has_paper_trail
  
  #attr_accessible :name, :description, :active, :rating
        
  # default scope
  default_scope where(:active => true)
 
  def self.max_rating 
    order("rating DESC").first.rating
  end
  def self.min_rating 
    order("rating ASC").first.rating
  end
  
  def self.from_rating(estimated_rating)
    ConditionType.where("rating = ?", [[estimated_rating.ceil, 1].max, 5].min).first unless estimated_rating.nil?
  end

end