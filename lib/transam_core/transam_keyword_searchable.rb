#------------------------------------------------------------------------------
#
# Transam Keyword Searchable
#
# Adds ability to index a model for keyword based searches. All models that use
# this plugin can be searched generically using the Transam keyword search
#
# To protect the privacy of organization sepcific data, each searchable object
# must implement an organization method that returns the organization that owns
# the object being searched. Implementations can determine through the database
# schema wether to allow null organization_id values or not. Each object must
# also return an Object Key.
#
#------------------------------------------------------------------------------
module TransamKeywordSearchable
  extend ActiveSupport::Concern

  included do

    # Always re-index the object after a save event
    after_save :update_index

    # Always remove the object from the index before it is destroyed
    before_destroy :remove_index

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

  #------------------------------------------------------------------------------
  # Removes the existing object from the index
  def remove_from_index
    kwsi = KeywordSearchIndex.find_by(object_key: object_key)
    if kwsi.present?
      kwsi.destroy
    end
  end
  #------------------------------------------------------------------------------
  # Writes the existing object to the index
  def write_to_index

    text_blob = ""
    separator = " "
    searchable_fields.each { |searchable_field|
      text_blob += self.send(searchable_field).to_s
      text_blob += separator
    }

    kwsi = KeywordSearchIndex.find_or_create_by(object_key: object_key) do |keyword_search_index|
      keyword_search_index.organization = self.organization
      keyword_search_index.context = self.class.name
      keyword_search_index.search_text = text_blob
      if self.is_a?(Asset)
        keyword_search_index.object_class = "Asset"
      else
        keyword_search_index.object_class = self.class.name
      end

      if respond_to? :description and self.description.present?
        keyword_search_index.summary = self.description.truncate(64)
      elsif respond_to? :name and self.name.present?
        keyword_search_index.summary = self.name.truncate(64)
      else
        keyword_search_index.summary = self.to_s
      end
    end

    # Save, catching errors
    save_with_exception_handler kwsi

  end
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Wrap the save method in an exception handler so that any schema-level problems
  # bubble up and can be caught without terminating the current transaction
  def save_with_exception_handler kwsi
    begin
      kwsi.save!
    rescue Exception => e
      Rails.logger.info "KeywordSearcher Error. Class = #{self.class.name}, Object Key = #{self.object_key}, Error = #{e.message}"
    end
  end

  # Creates a job to remove the object from the index. This is done in the background so the
  # current transaction does not get blocked. Default priority is 10
  def remove_index
    job = KeywordIndexDeleteJob.new(self.class.name, object_key)
    Delayed::Job.enqueue job, :priority => 10
  end

  # Creates a job to udpate the index. This is done in the background so the
  # current transaction does not get blocked. Default priority is 10
  def update_index
    job = KeywordIndexUpdateJob.new(self.class.name, object_key)
    Delayed::Job.enqueue job, :priority => 10
  end

end
