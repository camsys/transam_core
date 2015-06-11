class LicenseType < ActiveRecord::Base

  # associations
  has_many :customers

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

end
