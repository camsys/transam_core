class AssetEventType < ActiveRecord::Base

  # All order types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

end
