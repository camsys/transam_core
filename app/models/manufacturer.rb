class Manufacturer < ActiveRecord::Base

  # default scope
  default_scope { where(:active => true).order('code') }

  def asset_count(org)
    Asset.where(:organization_id => org.id, :manufacturer_id => id).count
  end

  def full_name
    "#{name} - #{filter.titleize}"
  end

  def to_s
    name
  end

end
