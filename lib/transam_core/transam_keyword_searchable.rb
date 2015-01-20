#------------------------------------------------------------------------------
#
# Transam Keyword Searchable
#
# Adds ability to index a model for keyword based searches. All models that use
# this plugin can be searched generically using the Transam keyword search
#
#------------------------------------------------------------------------------
module TransamKeywordSearchable
  extend ActiveSupport::Concern

  included do

    # Always re-index the object after a save event
    after_save :update_index

  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  # Returns a collection of classes that implement TransamKeywordSearchable
  def self.implementors
    ObjectSpace.each_object(Class).select { |klass| klass < TransamKeywordSearchable }
  end
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def write_to_index

    text_blob = ""
    separator = " "
    searchable_fields.each { |searchable_field|
      text_blob += self.send(searchable_field).to_s
      text_blob += separator
    }

    kwsi = KeywordSearchIndex.find_or_create_by(object_key: object_key) do |keyword_search_index|
      keyword_search_index.organization = organization
      keyword_search_index.context = self.class.name
      keyword_search_index.search_text = text_blob
      keyword_search_index.object_class = self.class.name
      if respond_to? :description
        keyword_search_index.summary = self.description
      else
        keyword_search_index.summary = self.name
      end
    end

    kwsi.save

  end
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Creates a job to udpate the index. This is done in the background so the
  # current transaction does not get bloacked. Default priority is 10
  def update_index
    job = KeywordIndexUpdateJob.new(self.class.name, object_key)
    Delayed::Job.enqueue job, :priority => 10
  end

end
