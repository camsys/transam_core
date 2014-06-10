module TransamHelper
  
  # From the application config    
  APP_VERSION = Rails.application.config.version   
  
  WARNING_CLASS     = "warning"
  ERROR_CLASS       = "error"
  
  ACTIVE_CLASS      = 'active'
  INACTIVE_CLASS    = 'inactive'
  
  # Return the version of TransAM core that is running
  def transam_version
    Gem.loaded_specs['transam_core'].version
  end
  
  # Returns the application version. This is the version defined in the host app
  # not the version of transam       
  def app_version
    APP_VERSION
  end

  def app_title
    title = ENV["APPLICATION_TITLE"] ? ENV["APPLICATION_TITLE"] : 'TransAM Application'
    return title.html_safe
  end
  
  def credits
    credit = ENV["APPLICATION_CREDITS"] ? ENV["APPLICATION_CREDITS"] : 'TransAM Core Asset Management Platform<br/>Configure me in Application.yml'
    return credit.html_safe
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
  
  # Returns a list of asset keys as a delimited string
  def list_to_delimited_string(list, delimiter = '|')
    str = ""
    list.each do |e|
      str << e 
      str << delimiter unless e == list.last
    end
    str
  end
    
  # returns a date as an array of elements suitable for creating a new date in javascript
  def js_date(date)
    [date.year,date.month,date.day].compact.join(',')
  end
  
  # returns a year as an array of elements suitable for creating a new date in javascript
  def js_year(year)
    [year,1,1].compact.join(',')
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
   
end