class AssetType < ActiveRecord::Base

  # associations

  # every asset type has 0 or more sub types
  has_many :asset_subtypes

  # All order types that are available
  scope :active, -> { where(:active => true) }
  
  def full_name
    "#{name} - #{description}"
  end

  def to_s
    name
  end

end
