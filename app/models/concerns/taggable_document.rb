module TaggableDocument
  extend ActiveSupport::Concern

  included do
    belongs_to :document_tag

    # returns boolean indicating whether or not update was successful
    def update_from_filename filename
      self.original_filename = filename
      self.valid?
    end
  end
end
