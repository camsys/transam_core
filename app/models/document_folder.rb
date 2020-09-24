class DocumentFolder < ApplicationRecord

  has_many :document_tags

  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

end
