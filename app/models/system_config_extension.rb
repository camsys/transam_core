# store all the mixins injected to base models thru added engines

class SystemConfigExtension < ApplicationRecord

  scope :active, -> { where(:active => true) }

end
