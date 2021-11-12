class AssetType < ActiveRecord::Base

  after_initialize  :set_defaults

  # associations

  # every asset type has 0 or more sub types
  has_many :asset_subtypes

  # All order types that are available
  scope :active, -> { where(:active => true) }
  
  def full_name
    "#{name} - #{description}"
  end

  def to_s
    name
  end

  def api_json(options={})
    {
      id: id,
      name: name, 
      description: description
    }
  end

  protected

  def set_defaults
    self.allow_parent = self.allow_parent.nil? ? true : self.allow_parent
  end

  #for bulk updates
  def self.schema_structure
    {
      "enum": AssetType.all.pluck(:name),
      "tuple": AssetType.all.map{ |s| {"id": s.id, "val": s.name} },
      "type": "string",
      "title": "Type"
    }
  end

end
