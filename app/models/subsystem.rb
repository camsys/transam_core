# A subsystem within an asset, more granular/smaller than Equipment
# e.g. transmission or engine on a vehicle or windows in a facility
class Subsystem < ActiveRecord::Base
  belongs_to :asset_type

  scope :for_type, ->(type_id) { where(asset_type_id: [type_id, nil]) } # NOTE: can handle id or coerce down an AssetType itself

  def to_s
    name
  end
end