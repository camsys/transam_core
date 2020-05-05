class SystemConfigFieldCustomization < ApplicationRecord

  scope :active, -> { where(:active => true) }

end
