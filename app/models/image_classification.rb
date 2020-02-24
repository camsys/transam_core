class ImageClassification < ApplicationRecord
  scope :active, -> { where(:active => true) }
  scope :for_category, ->(category) { where(:category => category) }

  default_scope { order(:sort_order) }

  def to_s
    name
  end
end
