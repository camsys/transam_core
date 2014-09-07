class Manufacturer < ActiveRecord::Base
          
  # default scope
  default_scope { where(:active => true).order('code') }

  def full_name
    "#{name} - #{filter.titleize}"
  end

  def to_s
    name
  end

end

