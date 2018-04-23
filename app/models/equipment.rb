class Equipment < Asset

  # Callbacks
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Associations common to all equipment assets
  #------------------------------------------------------------------------------

  validates :quantity,        :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}
  validates :quantity_units,  :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_type_id => AssetType.where(:class_name => self.name).pluck(:id)) }

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    [
      :quantity,
      :quantity_units
    ]
  end

  def transfer new_organization_id
    org = Organization.where(:id => new_organization_id).first

    transferred_asset = self.copy false
    transferred_asset.object_key = nil

    transferred_asset.disposition_date = nil
    transferred_asset.in_service_date = nil
    transferred_asset.organization = org
    transferred_asset.purchase_cost = nil
    transferred_asset.purchase_date = nil
    transferred_asset.purchased_new = false
    transferred_asset.service_status_type = nil

    transferred_asset.generate_object_key(:object_key)
    transferred_asset.asset_tag = transferred_asset.object_key

    transferred_asset.save(:validate => false)

    return transferred_asset
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge(
    {
      :quantity => self.quantity,
      :quantity_units => self.quantity_units
    })
  end

  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    a
  end

  def searchable_fields
    a = []
    a << super
    a += [
      :description,
      :serial_number
    ]
    a.flatten
  end

  def cleansable_fields
    a = []
    a << super
    a += [
      :quantity
    ]
    a.flatten
  end

  # The cost of a equipment asset is the purchase cost
  def cost
    purchase_cost
  end


  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a suppoert facility
  def set_defaults
    super
    self.quantity ||= 1
    self.quantity_units ||= Uom::UNIT
  end

end
