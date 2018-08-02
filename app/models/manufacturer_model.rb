class ManufacturerModel < ApplicationRecord

  scope :active, -> { where(:active => true) }

end
