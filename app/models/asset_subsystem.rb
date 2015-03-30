# A subsystem within an asset, more granular/smaller than Equipment
# e.g. transmission or engine on a vehicle or windows in a facility
class AssetSubsystem < ActiveRecord::Base
  belongs_to :asset_type
  has_many :asset_event_asset_subsystems

  scope :for_type, ->(type_id) { where(asset_type_id: [type_id, nil]) } # NOTE: can handle id or coerce down an AssetType itself

  validates :name, :presence => true

  def to_s
    name
  end
end