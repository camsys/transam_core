#-------------------------------------------------------------------------------
#
# Saved Query
#
# Represents a search that has been persisted to the database by the user
#
#-------------------------------------------------------------------------------
class SavedQuery < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Behaviors
  #-----------------------------------------------------------------------------

  # Include the object key mixin
  include TransamObjectKey

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize  :set_defaults

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  # Each saved search belongs to a user
  belongs_to        :created_by_user, :class_name => "User",  :foreign_key => :created_by_user_id
  belongs_to        :updated_by_user, :class_name => "User",  :foreign_key => :updated_by_user_id
  belongs_to        :shared_from_org, :class_name => "Organization",  :foreign_key => :shared_from_org_id

  has_and_belongs_to_many   :organizations

  has_many :saved_query_fields
  has_many :query_fields, through: :saved_query_fields
  
  has_many :query_filters

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  #validates         :created_by_user,        :presence => true
  #validates         :updated_by_user,        :presence => true
  validates         :name,        :presence => true, :uniqueness => {scope: :created_by_user, message: "should be unique per user"}
  validates         :description, :presence => true


  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------


  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :name,
    :description,
    :organization_ids => []
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
    :name,
    :description
  ]

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.searchable_fields
    SEARCHABLE_FIELDS
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  def to_s
    name
  end

  def shared?
    !organizations.empty?
  end

  # Caches the rows
  def data
    @data ||= perform_query
  end

  def to_sql
    relation.to_sql
  end

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  # Set reasonable defaults for a new saved search
  def set_defaults

  end

  # Perform query
  def perform_query
    relation
  end


  #-----------------------------------------------------------------------------
  #
  # Private Methods
  #
  #-----------------------------------------------------------------------------
  
  # Compose query relation
  def relation
    # base query relation for asset
    base_rel = TransamAsset

    # base query relation for configuration data
    config_rel = query_filters.joins(query_field: :query_asset_classes)

    # joins
    join_tables = config_rel.pluck("query_asset_classes.transam_assets_join").uniq.reject { |c| c.blank? }
    join_tables.each do |join_sql|
      base_rel = base_rel.joins(join_sql)
    end

    # wheres
    where_sqls = []
    # compose where sql for each query field
    where_sqls_for_one_filter = []
    last_filter_id = nil
    config_rel.order("query_filters.id").pluck(
      Arel.sql("query_filters.id"), 
      Arel.sql("query_asset_classes.table_name as query_table_name"),
      Arel.sql("query_fields.name as query_field_name"), 
      Arel.sql("query_filters.op as query_filter_op"), 
      Arel.sql("query_filters.value")).each do |config|
      filter_id = config[0]
      filter_sql = "#{config[1]}.#{config[2]} #{config[3]} (#{config[4]})"
      
      if last_filter_id && filter_id != last_filter_id
        where_sqls << where_sqls_for_one_filter.join(" OR ")
        where_sqls_for_one_filter = []
      else
        where_sqls_for_one_filter << filter_sql
      end
      last_filter_id = filter_id
    end 

    if where_sqls_for_one_filter.any?
        where_sqls << where_sqls_for_one_filter.join(" OR ")
    end
    # combine where_sqls
    if where_sqls.any?
      base_rel = base_rel.where(where_sqls.map{ |s| "(" + s + ")" }.join(" AND "))
    end

    # selects
    select_sqls = []
    output_configs = query_fields.joins(:query_asset_classes).pluck(
      Arel.sql("query_fields.name"), 
      Arel.sql("query_asset_classes.table_name"))
    output_configs.each do |config|
      select_sqls << "#{config[1]}.#{config[0]} as #{config[1]}_#{config[0]}"
    end 

    if select_sqls.any?
      base_rel = base_rel.select(select_sqls.join(", "))
    end

    base_rel
  end

end
