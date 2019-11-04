module TransamHelper

  # From the application config
  APP_VERSION = Rails.application.config.version

  WARNING_CLASS     = "warning"
  ERROR_CLASS       = "error"

  ACTIVE_CLASS      = 'active'
  INACTIVE_CLASS    = 'inactive'

  # Include the fiscal year mixin
  include FiscalYear

  def get_planning_fiscal_years_collection
    get_planning_fiscal_years
  end

  def get_fiscal_years_collection
    get_fiscal_years
  end

  def get_system_asset_starting_year
    SystemConfig.instance.epoch.year 
  end

  # return collection of earliest year to current year
  def get_years_to_date_collection
    (get_system_asset_starting_year..Date.today.year).to_a
  end

  # Return the version of TransAM core that is running
  def transam_version
    Gem.loaded_specs['transam_core'].version
  end

  # Returns the application version. This is the version defined in the host app
  # not the version of transam
  def app_version
    APP_VERSION
  end

  # returns application title set in environment, with fallback
  def app_title
    title = ENV["APPLICATION_TITLE"] ? ENV["APPLICATION_TITLE"] : 'TransAM Application'
    return title.html_safe
  end

  # returns credits set in environment, with fallback
  def credits
    credit = ENV["APPLICATION_CREDITS"] ? ENV["APPLICATION_CREDITS"] : 'TransAM Core Asset Management Platform<br/>Configure me in Application.yml'
    return credit.html_safe
  end

  def html_help_pdf_path(use_admin=false)
    config = Rails.application.config
    file = 'TransAMUserGuide.html'
    if use_admin && config.try(:admin_guide).present?
      file = config.admin_guide
    elsif config.try(:user_guide).present?
      file = config.user_guide
    end
    "#{config.help_directory}/#{file}"
  end

  def html_release_notes_pdf_path
    config = Rails.application.config
    file = config.release_notes.gsub('version_number', config.version.split('-')[0])
    "#{config.help_directory}/#{file}"
  end

  # Returns the correct FontAwesomne icon for a file type based on the
  # file extension
  def get_file_icon_for_filename(filename)
    ext = filename.split('.').last
    if ["doc", "docx"].include? ext
      icon = 'fa-file-word-o'
    elsif ["xls", "xlsx"].include? ext
      icon = 'fa-file-excel-o'
    elsif ["pdf"].include? ext
      icon = 'fa-file-pdf-o'
    elsif ["ppt"].include? ext
      icon = 'fa-file-powerpoint-o'
    else
      icon = 'fa-file-o'
    end
    icon
  end

  # Returns the tag icon classes (empty star or filled star) for an object based on
  # whether the object has been tagged by the user or not
  def get_tag_icon(obj)
    if obj.tagged? current_user
      'fa-star text-tagged taggable'
    else
      'fa-star-o text-tagged taggable'
    end
  end

  # Returns the message priority icon classes for an message based on
  # the message priority
  def get_message_priority_icon(msg)
    if msg.priority_type_id == 1
    elsif msg.priority_type_id == 2
      'fa-flag text-default'
    elsif msg.priority_type_id == 3
      'fa-flag text-danger'
    end
  end

  # Returns the correct icon for a workflow event
  def get_workflow_event_icon(event_name)

    if event_name == 'retract'
      'fa-eject'
    elsif event_name == 'transmit' || event_name == 'submit'
      'fa-share'
    elsif event_name == 'accept' || event_name == 'authorize'
      'fa-check-square-o'
    elsif event_name == 'start' || event_name == 'publish'
      'fa-play'
    elsif event_name == 'complete' || event_name == 'close'
      'fa-check-square'
    elsif event_name == 'cancel'
      'fa-stop'
    elsif event_name == 'not_authorize'
      'fa-ban'
    elsif event_name == 're_start'
      'fa-play'
    elsif event_name == 'halt'
      'fa-pause'
    elsif event_name == 'retract' || event_name == 'reopen'
      'fa-reply'
    elsif event_name == 'return' || event_name == 'reject' || event_name == 'unapprove'
      'fa-chevron-circle-left'
    elsif event_name == 'approve'
      'fa-plus-square'
    elsif event_name == 'approve_via_transfer'
      'fa-chevron-circle-right'
    else
      ''
    end
  end

  def bootstrap_class_for flash_type
    case flash_type
      when :success
        "alert-success alert-block"
      when :error
        "alert-error alert-block"
      when :alert
        "alert-warning alert-block"
      when :notice
        "alert-info alert-block"
      else
        flash_type.to_s
    end
  end

  # Maps priority_types to bootstrap text-* classes
  def bootstrap_class_priority_type priority_type
    case priority_type.id
    when 1
      "text-default"
    when 2
      "text-info"
    when 3
      "text-danger"
    else
      ""
    end
  end

  # Returns the system user.
  def system_user
    # By convention, the first user is always the system user.
    User.find_by_id(1)
  end

  # returns a date as an array of elements suitable for creating a new date in javascript
  def js_date(date)
    [date.year,(date.month) - 1,date.day].compact.join(',')
  end

  # returns a year as an array of elements suitable for creating a new date in javascript
  def js_year(year)
    [year,1,1].compact.join(',')
  end

  # Returns a list of asset keys as a delimited string
  def list_to_delimited_string(list, delimiter = '|')
    str = ""
    list.each do |e|
      str << e
      str << delimiter unless e == list.last
    end
    str
  end

  # Returns the class for the navigation link
  def get_nav_link_class(controller_name, session_var=nil, param_value=nil)
    if controller_name.kind_of?(Array)
      controller_name.each do |name|
        val = is_active_nav(name, session_var, param_value)
        if val
          return ACTIVE_CLASS
        end
      end
    else
      return is_active_nav(controller_name, session_var, param_value) ? ACTIVE_CLASS : INACTIVE_CLASS
    end
    return INACTIVE_CLASS
  end

  def is_active_nav(controller_name, session_var=nil, param_value=nil)
    val = false
    if params[:controller] == controller_name
      if session_var
        val = (session[session_var] == param_value)
      else
        val = true
      end
    end
    return val
  end

  # returns the current url with any new params tacked on
  def current_url(new_params)
    url_for params: params.permit!.merge(new_params) # allow all params already passed
  end

end
