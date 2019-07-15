class ImageClassification < ApplicationRecord
  scope :active, -> { where(:active => true) }
  scope :for_category, ->(category) { where(:category => category) }

  def to_s
    name
  end
end
