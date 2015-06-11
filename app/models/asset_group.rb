#------------------------------------------------------------------------------
# AssetGroup
#
# HBTM relationship with assets. Used as a generic bucket for grouping assets
# into loosely defined collections
#
#------------------------------------------------------------------------------
class AssetGroup < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------

  # Clear the mapping table when the group is destroyed
  before_destroy { assets.clear }

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every asset group is owned by an organization
  belongs_to :organization

  # Every asset grouop has zero or more assets
  has_and_belongs_to_many :assets

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # All order types that are available
  scope :active, -> { where(:active => true) }

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :organization,          :presence => true
  validates :name,                  :presence => true, :length => { maximum: 64 }, :uniqueness => {:scope => :organization, :message => "must be unique within an organization"}
  validates :code,                  :presence => true, :length => { maximum: 8 }
  validates :description,           :presence => true

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :organization_id,
    :name,
    :code,
    :description,
    :active
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
    :object_key,
    :name,
    :code,
    :description
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Returns true if the asset group contains a homogeneous set of asset types, false otherwise
  def homogeneous?
    asset_type_ids.length == 1
  end

  # Returns the unique set of asset_ids for assets stored in the group
  def asset_type_ids
    assets.scope.uniq.pluck(:asset_type_id)
  end

  def to_s
    name
  end

  def searchable_fields
    SEARCHABLE_FIELDS
  end

end
