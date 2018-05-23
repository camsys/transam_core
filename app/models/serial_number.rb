class SerialNumber < ApplicationRecord
  belongs_to :identifiable, polymorphic: true


end
