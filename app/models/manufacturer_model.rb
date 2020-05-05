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

end
