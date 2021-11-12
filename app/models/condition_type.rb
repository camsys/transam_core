class ConditionType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  def self.max_rating
    order("rating_ceiling DESC").first.rating_ceiling
  end
  def self.min_rating
    order("rating_ceiling ASC").first.rating_ceiling + 0.01
  end

  # Uses FTA's condition assessment ratings
  def self.from_rating(estimated_rating)
    if estimated_rating.nil? || estimated_rating < 0.0 || estimated_rating > 5.0
      rating = 0
    else
      rating = estimated_rating
    end
    ConditionType.order("rating_ceiling ASC").where("rating_ceiling >= ?", rating).first
  end

  def to_s
    name
  end

  #for bulk updates
  def self.schema_structure
    {
      "enum": ConditionType.all.pluck(:name),
      "tuple": ConditionType.all.map{ |x| {"id": x.id, "val": x.name} },
      "type": "string",
      "title": "Condition"
    }
  end

end
