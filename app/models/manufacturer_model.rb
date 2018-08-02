class ManufacturerModel < ApplicationRecord

  rails_admin

  scope :active, -> { where(:active => true) }

end
