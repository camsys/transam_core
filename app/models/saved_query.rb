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
  attr_accessor :organization_list

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
    :organization_ids => [],
    :query_field_ids => [],
    :query_filters => [:query_field_id, :value, :op]
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

  def parse_query_fields(query_field_ids, query_filters_data)
    self.query_fields = QueryField.where(id: query_field_ids)

    query_filters_data.each do |filter_data|
      self.query_filters << QueryFilter.new(filter_data)
    end
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
    base_rel = TransamAsset.where("transam_assets.organization_id": organization_list || [])

    join_tables = {}
    where_sqls = []
    query_filters.each do |filter|
      # exclude organization_id as its handled above
      next unless filter.query_field || filter.query_field.name == 'organization_id'

      where_sqls_for_one_filter = []
      filter.query_field.query_asset_classes.each do |asset_class|
        asset_table_name = asset_class.table_name
        unless join_tables.keys.include?(asset_table_name) || asset_class.transam_assets_join.blank?
          join_tables[asset_table_name] = asset_class.transam_assets_join
        end

        filter_value = filter.value
        # wrap values
        if filter.op == 'like'
          filter_value = "'%#{filter.value}%'"
        elsif ['date', 'type_ahead'].include?(filter.query_field.filter_type)
          filter_value = "'#{filter.value}'"
        end

        where_sqls_for_one_filter << "#{asset_table_name}.#{filter.query_field.name} #{filter.op} (#{filter_value})"
      end

      where_sqls << where_sqls_for_one_filter.join(" OR ")
    end

    # joins
    join_tables.each do |table_name, join_sql|
      base_rel = base_rel.joins(join_sql)
    end

    # wheres
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

    # return base query relation
    base_rel
  end

end
