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
      "enum": ManufacturerModel.where.not(name: "Other").pluck(:name),
      "tuple": ManufacturerModel.where.not(name: "Other").map{|m| {"id": m.id, "val": m.name } },
      "type": "string",
      "title": "Model"
    }
    
  end

end
