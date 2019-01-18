#-------------------------------------------------------------------------------
#
# Saved Query
#
# Represents a search that has been persisted to the database by the user
#
#-------------------------------------------------------------------------------
class SavedQuery < ActiveRecord::Base
  serialize :ordered_output_field_ids, Array

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

  has_many :saved_query_fields, dependent: :destroy
  has_many :query_fields, through: :saved_query_fields
  
  has_many :query_filters, dependent: :destroy

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
    query_field_ids = query_field_ids.map(&:to_i)
    visible_query_fields = QueryField.where(id: query_field_ids)
    # find pair fields
    paired_fields = QueryField.where(name: visible_query_fields.where.not(pairs_with: nil).pluck(:pairs_with).uniq)
    self.query_fields = visible_query_fields.or(paired_fields)

    # TODO: sort
    query_field_has_pairs_hash = visible_query_fields.where.not(pairs_with: nil).pluck(:id, :pairs_with).to_h
    paired_fields_hash = paired_fields.pluck(:name, :id).to_h
    query_field_has_pairs_hash.each do |field_id, pair_with_field_name|
      paired_field_id = paired_fields_hash[pair_with_field_name]
      idx = query_field_ids.index(field_id)
      query_field_ids.insert idx+1, paired_field_id
    end

    self.ordered_output_field_ids = query_field_ids

    filters = []
    (query_filters_data || []).each do |filter_data|
      filters << QueryFilter.new(filter_data)
    end

    self.query_filters = filters
  end

  def ordered_query_fields
    query_fields.sort_by{|f| self.ordered_output_field_ids.index(f.id)}
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
    where_sqls = {}
    field_pairs = {}
    query_filters.each do |filter|
      query_field = filter.query_field
      # exclude organization_id as its handled above
      next unless query_field || query_field.name == 'organization_id'
      unless query_field.pairs_with.blank?
        field_pairs[query_field.name] = query_field.pairs_with
      end

      where_sqls_for_one_filter = []
      query_field.query_asset_classes.each do |asset_class|
        asset_table_name = asset_class.table_name
        unless join_tables.keys.include?(asset_table_name) || asset_class.transam_assets_join.blank?
          join_tables[asset_table_name] = asset_class.transam_assets_join
        end

        query_field_name = "#{asset_table_name}.#{query_field.name}"
        query_filter_type = query_field.filter_type

        filter_value = filter.value
        # wrap values
        if filter.op == 'like'
          filter_value = "'%#{filter.value}%'"
        elsif ['date', 'text'].include?(query_filter_type)
          filter_value = "'#{filter.value}'"
        end

        filter_op = filter.op
        if filter_op == 'in' 
          if filter_value.blank?
            filter_op = 'is'
            filter_value = 'NULL'
          else
            filter_value = "(#{filter_value})"
          end
        end

        #if query_filter_type == 'text'
          #query_field_name = "lower(#{query_field_name})"
          #filter_value = "lower(#{filter_value})"
        #end

        where_sqls_for_one_filter << "#{query_field_name} #{filter_op} #{filter_value}"
      end

      where_sqls[query_field.name] = where_sqls_for_one_filter.join(" OR ")
    end

    # deal with field_pairs: if both the main field and pairs_with field are filters, then they should be a OR sql relation
    # e.g., manufacturer_id in (1,2) OR other_manufacturer in ('A', 'B')
    field_pairs.each do |main_field, pairs_with|
      main_field_sql = where_sqls[main_field]
      pairs_with_sql = where_sqls[pairs_with]
      next if main_field_sql.blank? || pairs_with_sql.blank? 
      where_sqls[main_field] = "(#{main_field_sql}) OR (#{pairs_with_sql})"
      where_sqls.delete(pairs_with) # delete pairs_with sql
    end

    select_sqls = []
    query_fields.each do |field|
      query_field_name = field.name
      field_association = field.query_association_class
      if field_association
        association_table_name = field_association.table_name
        association_id_field_name = field_association.id_field_name
        association_display_field_name = field_association.display_field_name
      end

      field.query_asset_classes.each do |qac|
        asset_table_name = qac.table_name
        table_join = qac.transam_assets_join

        unless join_tables.keys.include?(asset_table_name) || table_join.blank?
          join_tables[asset_table_name] = table_join
        end

        unless association_table_name.blank?
          as_table_name = "#{asset_table_name}_#{association_table_name}"
          # select value from association table
          unless join_tables.keys.include?(as_table_name)
            join_tables[as_table_name] = "left join #{association_table_name} as #{as_table_name} on #{as_table_name}.#{association_id_field_name} = #{asset_table_name}.#{query_field_name}"
          end
          select_sqls << "#{as_table_name}.#{association_display_field_name} as #{asset_table_name}_#{query_field_name}"
        else
          # select value directly from asset_table

          output_field_name = field.display_field.blank? ? "#{asset_table_name}.#{query_field_name}" : "#{asset_table_name}.#{field.display_field}"
          select_sqls << "#{output_field_name} as #{asset_table_name}_#{query_field_name}"
        end
      end
    end 

    # joins
    join_tables.each do |table_name, join_sql|
      base_rel = base_rel.joins(join_sql)
    end

    # wheres
    if where_sqls.any?
      base_rel = base_rel.where(where_sqls.map{ |field_name, field_sql| "(" + field_sql + ")" }.join(" AND "))
    end

    # selects
    if select_sqls.any?
      base_rel = base_rel.select("transam_assets.id", select_sqls.join(", "))
    end

    # return base query relation
    puts base_rel.to_sql
    base_rel
  end

end
