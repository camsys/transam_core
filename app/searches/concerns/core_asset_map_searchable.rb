# Asset map searcher in core engine
#
module CoreAssetMapSearchable

  extend ActiveSupport::Concern

  included do

    attr_accessor :organization_id, :asset_subtype_id

  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
  module ClassMethods

  end
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  private

  def organization_id_conditions
    # This method works with both individual inputs for organization_id as well
    # as arrays containing several organization ids.

    clean_organization_id = remove_blanks(organization_id)
    @klass.where(organization_id: clean_organization_id)
  end

  def asset_subtype_id_conditions
    clean_asset_subtype_id = remove_blanks(asset_subtype_id)
    @klass.where(asset_subtype_id: clean_asset_subtype_id) unless clean_asset_subtype_id.empty?
  end

end
