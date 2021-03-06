# --------------------------------
# # NOT USED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------

#-------------------------------------------------------------------------------
#
# Asset Tag
#
# Map relation that maps an asset to a user as part of a tag.
# User could star an asset as a favorite
#
#-------------------------------------------------------------------------------
class AssetTag < ActiveRecord::Base
  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  # Every asset_tag belongs to an asset
  belongs_to  :asset

  # Every asset_tag belongs to a user
  belongs_to  :user

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates     :asset,         :presence => true
  validates     :user,          :presence => true

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
  ]

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

end
