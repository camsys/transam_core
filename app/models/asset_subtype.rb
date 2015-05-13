class AssetSubtype < ActiveRecord::Base

  # Associations
  belongs_to :asset_type
  has_one    :policy_item

  # Validations
  validates :asset_type, presence: true

  # default scope
  default_scope { where(:active => true) }

  def full_name
    "#{name} - #{description}"
  end

  def to_s
    name
  end

end
