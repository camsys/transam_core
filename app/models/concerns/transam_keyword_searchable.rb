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

    # Assets: a save of only subclass fields (e.g. license_plate on a revenue vehicle) never
    # saves TransamAsset, but acts_as touches it. Check here too so that change still
    # gets indexed (TTPLAT-3100).
    after_touch     :check_for_changes, if: -> { respond_to?(:all_changes) }

    after_commit    :update_index, on: [:create, :update]      # was after_save; runs once per object per transaction

    after_rollback  { self.is_dirty = false }

    # Always remove the object from the index before it is destroyed
    before_destroy  :remove_index

    # Set a local instance variable to determine if the index needs to be updated
    attr_accessor   :is_dirty

    #-----------------------------------------------------------------------------
    # Removes the existing object from the index
    #-----------------------------------------------------------------------------
    def self.remove_from_index object_key
      kwsi = KeywordSearchIndex.find_by(object_key: object_key)
      if kwsi.present?
        kwsi.destroy
      else
        Rails.logger.info "Can't find #{self.name} with object_key #{object_key}"
      end
    end

  end

  #-----------------------------------------------------------------------------
  # Class Methods
  #-----------------------------------------------------------------------------

  module ClassMethods

  end

  # Returns a collection of classes that implement TransamKeywordSearchable
  def self.implementors
    ObjectSpace.each_object(Class).select { |klass| klass < TransamKeywordSearchable }
  end

  #-----------------------------------------------------------------------------
  # Instance Methods
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Writes the existing object to the index
  #-----------------------------------------------------------------------------
  def write_to_index

    # Boolean to determine if the index should be written (transferred assets that are incomplete should not be)
    should_write_to_index = true

    # Create a blob of unique search keys for this instance
    a = []
    separator = " "
    searchable_fields.each { |searchable_field|
      if Rails.application.config.asset_base_class_name == self.class.to_s
        a << Rails.application.config.asset_base_class_name.constantize.get_typed_asset(self).send(searchable_field).to_s
      else
        a << self.send(searchable_field).to_s
      end

    }
    text = a.uniq.compact.join(' ')

    keyword_search_index = KeywordSearchIndex.find_or_create_by(object_key: object_key)

    keyword_search_index.organization_id = self.organization.id
    keyword_search_index.context = self.class.name
    keyword_search_index.search_text = text
    if self.is_a?(Rails.application.config.asset_base_class_name.constantize)
      # Don't create keyword indexes for keyword assets
      incomplete_transferred_asset? ? should_write_to_index = false : should_write_to_index = true
      keyword_search_index.object_class = Rails.application.config.asset_base_class_name
    else
      keyword_search_index.object_class = self.class.name
    end

    # Save, catching errors
    if should_write_to_index
      if respond_to? :description and self.description.present?
        keyword_search_index.summary = self.description.truncate(64)
      elsif respond_to? :name and self.name.present?
        keyword_search_index.summary = self.name.truncate(64)
      else
        keyword_search_index.summary = self.to_s
      end

      save_with_exception_handler keyword_search_index
    end

  end

  def build_index_object
    # Boolean to determine if the index should be written (transferred assets that are incomplete should not be)
    should_write_to_index = true

    # Create a blob of unique search keys for this instance
    a = []
    separator = " "
    searchable_fields.each { |searchable_field|
      if Rails.application.config.asset_base_class_name == self.class.to_s
        a << Rails.application.config.asset_base_class_name.constantize.get_typed_asset(self).send(searchable_field).to_s
      else
        a << self.send(searchable_field).to_s
      end
    }
    text = a.uniq.compact.join(' ')

    keyword_search_index = KeywordSearchIndex.new(object_key: object_key)
    keyword_search_index.organization_id = self.organization.id if self.organization
    keyword_search_index.context = self.class.name
    keyword_search_index.search_text = text
    if self.is_a?(Rails.application.config.asset_base_class_name.constantize)
      incomplete_transferred_asset? ? should_write_to_index = false : should_write_to_index = true
      keyword_search_index.object_class = Rails.application.config.asset_base_class_name
    else
      keyword_search_index.object_class = self.class.name
    end

    # Save, catching errors
    if should_write_to_index
      if respond_to? :description and self.description.present?
        keyword_search_index.summary = self.description.truncate(64)
      elsif respond_to? :name and self.name.present?
        keyword_search_index.summary = self.name.truncate(64)
      else
        keyword_search_index.summary = self.to_s
      end
    end

    keyword_search_index
  end
  
  #-----------------------------------------------------------------------------
  # Protected Methods
  #-----------------------------------------------------------------------------
  protected

  # Checks the pre-saved instance for changes and sets the dirty flag is any
  # changes are detected
  def check_for_changes
    Rails.logger.debug "checking for changes"
    # No reset to false here: is_dirty stays true until update_index (after_commit) or
    # after_rollback clears it, so a later save in the same transaction can't undo it.

    # Assets: changes from every level of the acts_as chain (TTPLAT-3100). Others: their own changes.
    changed = self.respond_to?(:all_changes) ? self.all_changes : self.changes
    searchable_fields.each do |searchable_field|
      Rails.logger.debug "Testing property #{searchable_field}"
      field = searchable_field.to_s
      # Association fields (manufacturer_model, fta_type) show up as their foreign key columns
      if changed.key?(field) || changed.key?("#{field}_id") || changed.key?("#{field}_type")
        Rails.logger.debug "#{field} has changed"
        self.is_dirty = true
        return
      end
    end
    return
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
      begin
        job = KeywordIndexUpdateJob.new(self.class.name, object_key)
        Delayed::Job.enqueue job, :priority => 10
      rescue => e
        Rails.logger.error "KeywordSearcher enqueue failed. Class = #{self.class.name}, Object Key = #{object_key}, Error = #{e.message}"
      ensure
        self.is_dirty = false
      end
    end
  end

  # Determines if an asset is transferred
  def incomplete_transferred_asset?
    return self.is_a?(Rails.application.config.asset_base_class_name.constantize) && self.object_key.to_s == self.asset_tag.to_s
  end
end
