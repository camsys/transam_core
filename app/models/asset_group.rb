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

  # default scope
  default_scope { where(:active => true) }

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :organization,          :presence => true
  validates :name,                  :presence => true, :length => { maximum: 64 }
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

  def to_s
    name
  end

  def homogeneous?
    asset_type_ids.length == 1
  end

  def heterogeneous?
    !homogeneous
  end

  # .scope returns the ActiveRecord::Relation for the assets, so we can 
  # do the uniqueness with a DISTINCT in SQL instead of in-memory
  def asset_type_ids
    assets.scope.uniq.pluck(:asset_type_id)
  end

  def searchable_fields
    SEARCHABLE_FIELDS
  end

end
