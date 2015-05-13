class Manufacturer < ActiveRecord::Base

  has_many :assets

  # default scope
  default_scope { order('code') }

  # Manufacturers that are maked as active
  scope :active, -> { where(:active => true) }
  # Notices that are active and visible for a specific organization
  scope :active_for_asset_type, -> (asset_type) { active.where("filter = ?", asset_type.class_name) }

  def self.search(text, exact = true, **params) # **params is a ruby parameter "hash-splat"
    if exact
      x = where('name = ? OR code = ?', text, text)
    else
      val = "%#{text.upcase}%"
      x = where('UPPER(name) LIKE ? OR UPPER(code) LIKE ?', val, val)
    end
    x = x.where(params) if params
    x.first
  end


  def asset_count(org)
    Asset.where(:organization_id => org.id, :manufacturer_id => id).count
  end

  def full_name
    name
  end

  def to_s
    code
  end

end
