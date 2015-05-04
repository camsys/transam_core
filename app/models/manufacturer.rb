class Manufacturer < ActiveRecord::Base

  has_many :assets

  # default scope
  default_scope { where(:active => true).order('code') }

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
    "#{name} - #{filter.titleize}"
  end

  def to_s
    code
  end

end
