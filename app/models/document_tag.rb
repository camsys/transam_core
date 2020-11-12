class DocumentTag < ApplicationRecord

  belongs_to :document_folder

  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

end
