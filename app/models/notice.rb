#------------------------------------------------------------------------------
#
# Notice
#
# Represents a business activity that is requried to be completed
# Needs standardizing between active vs end_datetime.  Views use end_datetime
#------------------------------------------------------------------------------
class Notice < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  attr_accessor :display_date
  attr_accessor :display_hour
  attr_accessor :end_date
  attr_accessor :end_hour

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults
  before_validation :calculate_datetimes_from_virtual_attributes

  #------------------------------------------------------------------------------
  #
  # Virtual Attributes
  #
  # Build the datetimes from a date and an hour, passed as strings
  #------------------------------------------------------------------------------
  def display_datetime_date
    display_datetime.to_date if display_datetime
  end
  def display_datetime_hour
    display_datetime.hour if display_datetime
  end
  def display_datetime_date=(date_str)
    Rails.logger.debug "in display_datetime_date #{date_str}"
    self.display_date = Chronic.parse(date_str).to_date
  end
  def display_datetime_hour=(hr_str)
    Rails.logger.debug "in display_datetime_hour #{hr_str}"
    self.display_hour = hr_str
  end

  def end_datetime_date
    end_datetime.to_date if end_datetime
  end
  def end_datetime_hour
    end_datetime.hour if end_datetime
  end

  def end_datetime_date=(date_str)
    Rails.logger.debug "in end_datetime_date #{date_str}"
    self.end_date = Chronic.parse(date_str).to_date
  end
  def end_datetime_hour=(hr_str)
    Rails.logger.debug "in end_datetime_hour #{hr_str}"
    self.end_hour = hr_str
  end


  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every notice has an optional organizatiopn type that that can see the notice
  belongs_to :organization
  belongs_to :notice_type

  # Every notice must have a defined type
  belongs_to :notice_type

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :subject,           :presence => true, :length => {:maximum => 64}
  validates :summary,           :presence => true, :length => {:maximum => 254}
  validates :display_datetime,  :presence => true
  validates :end_datetime,      :presence => true
  validates :notice_type,       :presence => true
  validate  :validate_end_after_start

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :organization_id,
    :subject,
    :summary,
    :details,
    :display_icon_name,
    :display_datetime_date,
    :display_datetime_hour,
    :end_datetime_date,
    :end_datetime_hour,
    :notice_type_id,
    :active
  ]

  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  # Notices that are maked as active
  scope :active, -> { where(:active => true) }
  # Notices that have a start time before current date/time and an end time before current date/time
  scope :visible, -> { active.where("? BETWEEN display_datetime AND end_datetime", DateTime.current) }
  # Notices that are for the entire set of organizations
  scope :system_level_notices, -> { active.visible.where("organization_id IS null") }
  # Notices that are active and visible for a specific organization
  scope :active_for_organization, -> (org) { active.visible.where("organization_id IS null OR organization_id = ?", org.id) }

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def visible?
    now = Time.now
    if display_datetime < now and now < end_datetime
      true
    else
      false
    end
  end
  # Return the duration of a notice's display in hours
  def duration_in_hours
    float_duration = (end_datetime - display_datetime)/3600
    float_duration.ceil # Round up to nearest hour
  end

  def to_s
    subject
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new notice
  # Datetime attributes are set in the following order
  # 1. Stored DB datetime
  # 2. Parsed from form_params
  # 3. Set as defaults (beginning of the next hour, end of today)
  def set_defaults
    self.active = true if self.active.nil?
    self.display_datetime ||= parsed_display_datetime_from_virtual_attributes || (DateTime.current.beginning_of_hour)
    self.end_datetime ||= parsed_end_datetime_from_virtual_attributes || display_datetime.end_of_day
  end

  # Before validating, ensure that we have converted from virtual attributes
  # to native ones
  def calculate_datetimes_from_virtual_attributes

    self.display_datetime = parsed_display_datetime_from_virtual_attributes || (DateTime.current.beginning_of_hour)
    self.end_datetime     = parsed_end_datetime_from_virtual_attributes || display_datetime.end_of_day

  end

  # Returns nil if a bad parse
  def parsed_display_datetime_from_virtual_attributes
    Rails.logger.debug "in parsed_display_datetime_from_virtual_attributes: #{display_date} #{display_hour}"
    dt = Chronic.parse("#{display_date} #{display_hour}")
    Rails.logger.debug "parsed value = #{dt}"
    return dt
  end

  # Returns nil if a bad parse
  def parsed_end_datetime_from_virtual_attributes
    Rails.logger.debug "in parsed_end_datetime_from_virtual_attributes #{end_date} #{end_hour}"
    dt = Chronic.parse("#{end_date} #{end_hour}")
    Rails.logger.debug "parsed value = #{dt}"
    return dt
  end

  def validate_end_after_start
    if end_datetime < display_datetime
      errors.add(:end_datetime, "must be after start time")
    end
  end

end
