class ConditionType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }
 
  def self.max_rating
    order("rating DESC").first.rating
  end
  def self.min_rating
    where('name <> ?', 'Unknown').order("rating ASC").first.rating
  end

  # Uses FTA's condition assessment ratings
  def self.from_rating(estimated_rating)
    return if estimated_rating.nil?
    if estimated_rating >= 4.8
      rating = 5
    elsif estimated_rating >= 4.0
      rating = 4
    elsif estimated_rating >= 3.0
      rating = 3
    elsif estimated_rating >= 2.0
      rating = 2
    else
      rating = 1
    end
    ConditionType.find_by_rating(rating)
  end

  def to_s
    name
  end

end
