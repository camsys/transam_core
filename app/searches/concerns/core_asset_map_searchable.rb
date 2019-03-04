# Asset map searcher in core engine
#
module CoreAssetMapSearchable

  extend ActiveSupport::Concern

  included do

    attr_accessor :organization_id, :asset_subtype_id, :asset_tag, :condition_rating_slider, :purchase_year_slider, :scheduled_replacement_year_slider

  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
  module ClassMethods

  end
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  private

  def organization_id_conditions
    # This method works with both individual inputs for organization_id as well
    # as arrays containing several organization ids.

    clean_organization_id = remove_blanks(organization_id)
    @klass.where(organization_id: clean_organization_id)
  end

  def asset_subtype_id_conditions
    clean_asset_subtype_id = remove_blanks(asset_subtype_id)
    @klass.where(asset_subtype_id: clean_asset_subtype_id) unless clean_asset_subtype_id.empty?
  end

  def asset_tag_conditions
    @klass.where("asset_tag LIKE ?", "%#{asset_tag}%") unless asset_tag.blank?
  end

  def condition_rating_conditions
    unless condition_rating_slider.blank?
      condition_ratings = condition_rating_slider.split(',')
      @klass.joins('LEFT JOIN recent_asset_events_views AS recent_rating ON recent_rating.base_transam_asset_id = transam_assets.id AND recent_rating.asset_event_name = "Condition"').joins('LEFT JOIN asset_events AS rating_event ON rating_event.id = recent_rating.asset_event_id').where(rating_event: {assessed_rating: condition_ratings[0].to_i..condition_ratings[1].to_i}) unless condition_ratings.empty?
    end
  end

  def purchase_year_conditions
    unless purchase_year_slider.blank?
      purchase_years = purchase_year_slider.split(',')
      @klass.where(purchase_date: Date.new(purchase_years[0].to_i,1,1)..Date.new(purchase_years[1].to_i,12,31))  unless purchase_years.empty?
    end
  end

  def scheduled_replacement_year_conditions
    unless scheduled_replacement_year_slider.blank?
      replacement_years = scheduled_replacement_year_slider.split(',')
      @klass.where(scheduled_replacement_year: replacement_years[0].to_i..replacement_years[1].to_i)  unless replacement_years.empty?
    end
  end

end
