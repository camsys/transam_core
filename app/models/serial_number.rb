class SerialNumber < ApplicationRecord
  belongs_to :identifiable, polymorphic: true

  validates :identifiable, presence: true
  validates :identification, presence: true

  def to_s
    identification
  end
end
