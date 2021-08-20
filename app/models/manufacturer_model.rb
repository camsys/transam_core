class ManufacturerModel < ApplicationRecord

  scope :active, -> { where(:active => true) }

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

  #for bulk updates
  def self.schema_structure
    {
      "enum": ManufacturerModel.all.pluck(:name),
      "type": "string",
      "title": "Model"
    }
    
  end

end
