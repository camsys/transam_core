module TaggableDocument
  extend ActiveSupport::Concern

  included do
    belongs_to :document_tag
  end
end
