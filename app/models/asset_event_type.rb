class AssetEventType < ActiveRecord::Base

  # All order types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  def api_json(options={})
    {
      name: name,
      description: description
    }
  end

end
