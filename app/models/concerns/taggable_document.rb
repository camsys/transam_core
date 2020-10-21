module TaggableDocument
  extend ActiveSupport::Concern

  included do
    belongs_to :document_tag
    singleton_class.prepend ClassOverrides
  end

  attr_accessor :attributes_from_file_name
  attr_accessor :folder

  # returns boolean indicating whether or not update was successful
  def update_from_filename filename
    self.original_filename = filename
    self.valid?
  end

  module ClassOverrides
    def allowable_params
      Document::FORM_PARAMS << [:document_tag_id, :file_date]
    end
  end
    
end
