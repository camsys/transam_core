class FuelType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  def self.search(text, exact = true)
    if exact
      x = where('name = ? OR code = ? OR description = ?', text, text, text).first
    else
      val = "%#{text}%"
      x = where('name LIKE ? OR code LIKE ? OR description LIKE ?', val, val, val).first
    end
    x
  end

  def to_s
    "#{code}-#{name}"
  end

  def api_json(options={})
    as_json(options)
  end

  def dotgrants_json
    {
      id: id,
      name: name,
      code: code
    }
  end

  # for bulk updates
  def self.schema_structure
    {
      "enum": FuelType.all.pluck(:name),
      "tuple": FuelType.all.map{|f| {"id": f.id, "val": f.name } },
      "type": "string",
      "title": "Fuel Type"
    }
  end

end
