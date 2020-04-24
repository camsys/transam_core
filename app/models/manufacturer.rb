class Manufacturer < ActiveRecord::Base

  has_many :assets
  has_many :transam_assets

  # default scope
  default_scope { order('code') }

  # Manufacturers that are maked as active
  scope :active, -> { where(:active => true) }
  scope :active_for_asset_type, -> (asset_type) { active.where("filter = ?", asset_type.class_name) }


  def self.search(text, filter, exact = true)
    if exact
      x = where('(name = ? OR code = ?) AND filter = ?', text, text, filter)
    else
      val = "%#{text}%"
      x = where('(name LIKE ? OR code LIKE ?) AND filter = ?', val, val, filter)
    end
    x.first
  end


  def asset_count(org)
    Asset.where(:organization_id => org.id, :manufacturer_id => id).count
  end

  def full_name
    name
  end

  def to_s
    "#{code} - #{name}"
  end

  def api_json(options={})
    {
      id: id,
      name: name, 
      code: code
    }
  end

end
