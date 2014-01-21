class Manufacturer < ActiveRecord::Base
          
  # default scope
  default_scope { where(:active => true).order('code') }

end

