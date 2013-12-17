module TransamHelper
  
  WARNING_CLASS     = "warning"
  ERROR_CLASS       = "error"
  
  ACTIVE_CLASS      = 'active'
  INACTIVE_CLASS    = 'inactive'
  
  def bootstrap_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-error"
      when :alert
        "alert-block"
      when :notice
        "alert-info"
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
  
  # truncates any decimals and returns the number as currency
  def format_as_currency(val)
    number_to_currency(val.to_i, :precision => 0)
  end
    
  def get_boolean(val)
    if val
      return "<i class='icon-ok'></i>".html_safe
    end
    #return val.nil? ? 'N' : val == true ? 'Y' : 'N'
  end
  
  # returns a date as an array of elements suitable for creating a new date in javascript
  def js_date(date)
    [date.year,date.month,date.day].compact.join(',')
  end
  # returns a year as an array of elements suitable for creating a new date in javascript
  def js_year(year)
    [year,1,1].compact.join(',')
  end
  
  # returns the Bootstrap warning class (if any) for the asset using TERM' replacement threshold of 2.5
  def get_asset_warning_class(asset)
    c = ""
    if asset && asset.asset_type_id == 1
      rating = asset.get_estimated_condition
      if rating <= 2.0
        c = ERROR_CLASS
      elsif rating == 2.5
        c = WARNING_CLASS
      end
    end
    return c
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
  
  def format_date_time_distance(datetime)
    dist = distance_of_time_in_words_to_now(datetime)
    if Time.now > datetime
      dist = dist + " ago"
    end  
    return dist
  end
  
  def format_date_time(datetime)
    return datetime.strftime("%I:%M %p %b %d %Y") unless datetime.nil?
  end
  def format_date(date)
    return date.strftime("%b %d %Y") unless date.nil?
  end
  def format_time(time)
    return time.strftime("%I:%M") unless time.nil?
  end
  
  def format_list_field(label,  value)
    html = "<div class='popup-row'>"
    html << "<label>"
    html << label
    html << "</label>"
    html << "<p style='margin-left:10px;margin-top:5px;margin-bottom:5px;'>"
    html << value.to_s unless value.nil?
    html << "</p>"
    html << "</div>"
    return html.html_safe    
  end
  
  def format_field(label, value, popover_text=nil)
 
    html = "<div class='row-fluid control-group'>"
    html << "<div class='span4 display-label'>"
    html << label
    html << "</div>"
    html << "<div class='span8 display-value'>"
    html << value.to_s unless value.nil?
    unless popover_text.nil?
      html << '&nbsp;'
      html << "<a href='#' class='info_icon' data-toggle='popover' title='Information' data-placement='top' data-content='" + popover_text + "'><i class='icon icon-info-sign'></i></a>"
    end
    html << "</div>"
    html << "</div>"
    
    return html.html_safe    
    
  end

  def image_thumbnail_tag(options={}, &block)

    # Check to see if there is any content in the block    
    content = capture(&block)
    if content.nil?      
      content = "<p>&nbsp;</p>"
    end

    html = "<div data-action-path='"
    html << options[:path]
    html << "'>"
    html << "<div class='well well-small' style='margin-bottom:0px;height:150px;'>"

    html << content

    html << "</div>"
    html << "</div>"
    
    return html.html_safe     
  end

  def action_thumbnail_tag(options={}, &block)

    # Check to see if there is any content in the block    
    content = capture(&block)
    if content.nil?      
      content = "<p>&nbsp;</p>"
    end

    html = "<div data-action-path='"
    html << options[:path]
    html << "'>"
    html << "<div class='well well-small' style='margin-bottom:0px;height:150px;'>"
    html << "<div class='row-fluid'>"
    html << "<div class='span4'>"
    html << "<i class='"
    html << options[:icon]
    html << " icon-4x' style='margin-top:5px;'></i>"
    html << "</div>"
    html << "<div class='span8'>"
    html << "<h4>"
    html << options[:title]
    html << "</div>"
    html << "</div>"
    html << "<div class='row-fluid'>"
    html << "<div class='span12'>"

    html << content

    html << "</div>"
    html << "</div>"
    html << "</div>"
    html << "</div>"
    
    return html.html_safe     
  end

  def subnav_elem_tag(&block)

    content = capture(&block)
    html = "<li>"    
    html << content 
    html << "</li>"
        
    return html.html_safe
  end
  def subnav_tag(options={}, &block)
    
    # Check to see if there is any content in the block    
    content = capture(&block)
    if content.nil?      
      content = "<p>&nbsp;</p>"
    end

    html = "<div class='row-fluid "
    html << options[:class] unless options[:class].blank?
    html << "'>"
    html << "<div class='span12'>"
    html << "<div class='navbar'>"
    html << "<div class='navbar-inner'>"
    html << "<ul class='nav'>"
    html << content
    html << "</ul>"
    html << "</div>"
    html << "</div>"
    html << "</div>"
    html << "</div>"
    
    return html.html_safe     
  end

  def panel_tag(panel_name, options={}, &block)
    
    # Check to see if there is any content in the block    
    content = capture(&block)
    if content.nil?      
      content = "<p>&nbsp;</p>"
    end

    html = "<li class='thumbnail shadow "
    html << options[:class] unless options[:class].blank?
    html << "'>"
    html << "<div class='dialog-title-bar panel-header corner-top'>"
    html << "<div class='row-fluid'>"
    html << "<h4 class='span12 dialog-title'>"
    if options[:icon]
      html << "<i class='"
      html << options[:icon]
      html << "'></i> "
    end
    html << panel_name
    html << "</h4>"

    html << "</div>"
    html << "</div>"
    html << "<div class='dialog-content'>"    
    html << content
    html << "</div>"
    html << "</li>"
    
    return html.html_safe     
  end
  
  def dialog_tag(dialog_name, icon=nil, link_text=nil, link_path=nil, &block)    
    # Check to see if there is any content in the block    
    content = capture(&block)
    if content.nil?      
      content = "<p>&nbsp;</p>"
    end
    
    html = "<li class='span12 thumbnail first-in-row shadow'>"
    html << "<div class='dialog-title-bar navbar-inner corner-top'>"
    html << "<div class='row-fluid'>"
    if link_path.nil?
      html << "<h4 class='span12 dialog-title'>"
      if icon
        html << "<i class='"
        html << icon
        html << "'></i> "
      end
      html << dialog_name
      html << "</h4>"
    else
      html << "<h4 class='span6 dialog-title'>"
      if icon
        html << "<i class='"
        html << icon
        html << "'></i> "
      end
      html << dialog_name
      html << "</h4>"
      html << "<div class='span6 dialog-controls'>"
      html << link_to(link_text, link_path, :class => "btn btn-small pull-right")
      html << "</div>"
    end
    html << "</div>"
    html << "</div>"
    html << "<div class='dialog-content'>"    
    html << content
    html << "</div>"
    html << "</li>"
    return html.html_safe    
  end
    
end