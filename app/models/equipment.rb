class Equipment < Asset

  # Enable auditing of this model type. Only monitor uodate and destroy events
  #has_paper_trail :on => [:update, :destroy]

  # Callbacks
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Associations common to all equipment assets
  #------------------------------------------------------------------------------

  validates :quantity,        :presence => :true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 1}
  validates :quantity_units,  :presence => true
  validates :description,     :presence => true

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
    FORM_PARAMS
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
  end

end
