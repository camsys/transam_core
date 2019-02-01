class DistrictType < ActiveRecord::Base

  has_many :districts

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

end
