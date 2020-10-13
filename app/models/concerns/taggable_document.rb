module TaggableDocument
  extend ActiveSupport::Concern

  included do
    belongs_to :document_tag
    validates :document_tag_id, :presence => true
  end

  attr_accessor :attributes_from_file_name
  attr_accessor :folder

  def self.form_params
    FORM_PARAMS + :document_tag_id
  end

  # returns boolean indicating whether or not update was successful
  def update_from_filename filename
    self.original_filename = filename
    self.valid?
  end

end
