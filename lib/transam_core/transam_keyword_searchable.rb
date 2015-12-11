#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------
module TransamKeywordSearchable
  extend ActiveSupport::Concern

  included do

    # Run a check before saving to see if any of the search properties are changed
    before_save     :check_for_changes

    # Always re-index the object after a save event
    after_save      :update_index

    # Always remove the object from the index before it is destroyed
    before_destroy  :remove_index

    # Set a local instance variable to determine if the index needs to be updated
    attr_accessor   :is_dirty

  end

  #-----------------------------------------------------------------------------
  # Class Methods
  #-----------------------------------------------------------------------------

  # Returns a collection of classes that implement TransamKeywordSearchable
  def self.implementors
    ObjectSpace.each_object(Class).select { |klass| klass < TransamKeywordSearchable }
  end

  #-----------------------------------------------------------------------------
  # Instance Methods
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Removes the existing object from the index
  #-----------------------------------------------------------------------------
  def remove_from_index
    kwsi = KeywordSearchIndex.find_by(object_key: object_key)
    if kwsi.present?
      kwsi.destroy
    end
  end
  #-----------------------------------------------------------------------------
  # Writes the existing object to the index
  #-----------------------------------------------------------------------------
  def write_to_index

    # Create a blob of unique search keys for this instance
    a = []
    separator = " "
    searchable_fields.each { |searchable_field|
      a << self.send(searchable_field).to_s
    }
    text = a.uniq.compact.join(' ')

    kwsi = KeywordSearchIndex.find_or_create_by(object_key: object_key) do |keyword_search_index|
      keyword_search_index.organization_id = self.respond_to? :organization_id ? self.organization_id : 0
      keyword_search_index.context = self.class.name
      keyword_search_index.search_text = text
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


  #-----------------------------------------------------------------------------
  # Protected Methods
  #-----------------------------------------------------------------------------
  protected

  # Checks the pre-saved instance for changes and sets the dirty flag is any
  # changes are detected
  def check_for_changes
    Rails.logger.debug "checking for changes"
    self.is_dirty = false
    searchable_fields.each do |searchable_field|
      Rails.logger.debug "Testing property #{searchable_field}"
      if self.changes.include? searchable_field.to_s
        Rails.logger.debug "#{searchable_field.to_s} has changed"
        self.is_dirty = true
        break
      end
    end
  end

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
    if self.is_dirty
      job = KeywordIndexUpdateJob.new(self.class.name, object_key)
      Delayed::Job.enqueue job, :priority => 10
      self.is_dirty = false
    end
  end

end
