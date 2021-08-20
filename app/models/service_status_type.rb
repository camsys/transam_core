class ServiceStatusType < ActiveRecord::Base

  scope :active, -> { where(active: true) }

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
    name
  end

  def api_json(options={})
    as_json(options)
  end

  # for bulk updates
  def self.schema_structure
    {
      "enum": ServiceStatusType.all.pluck(:name),
      "type": "string",
      "title": "Service Status"
    }
    
  end

end
