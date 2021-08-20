class AssetSubtype < ActiveRecord::Base

  # Associations
  belongs_to :asset_type

  # Validations
  validates :asset_type, presence: true

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
      asset_type: asset_type.try(:api_json, options),
      name: name, 
      description: description
    }
  end

  #for bulk updates
  def self.schema_structure
    {
      "enum": AssetSubtype.all.pluck(:name),
      "type": "string",
      "title": "Subtype"
    }
  end

end
