module TransamFormatHelper
        
  # formats a URL as a link
  def format_as_url(url, target = '_blank')
    link_to(url, url, target: "_blank")
  end      
  
  # truncates any decimals and returns the number as currency
  def format_as_currency(val)
    number_to_currency(val.to_i, :precision => 0)
  end

  # returns a number as a decimal
  def format_as_decimal(val, precision = 2)
    number_with_precision(val, :precision => precision)
  end

  # returns a number as a percentage
  def format_as_percentage(val, precision = 0)
    "#{number_with_precision(val, :precision => precision)}%"
  end

  # returns a number formatted as a phone number
  def format_as_phone_number(val, area_code = true)
    number_to_phone(val, :area_code => area_code)
  end
  
  # returns a collection as a formatted list
  def format_as_list(coll)
    html = "<ul class='unstyled'>"
    coll.each do |e|
      html << "<li>"
      html << e.to_s
      html << "</li>"
    end
    html << "</ul>"
    html.html_safe
  end    

  # formats a boolean field 
  def format_as_boolean(val)
    if val
      return "<i class='fa fa-check fa-fw'></i>".html_safe
    end
  end
        
  # formats a date/time as a distance in words. e.g. 6 days ago
  def format_as_date_time_distance(datetime)
    dist = distance_of_time_in_words_to_now(datetime)
    if Time.now > datetime
      dist = dist + " ago"
    end  
    return dist
  end
  
  # Standard formats for dates and times
  def format_as_date_time(datetime)
    return datetime.strftime("%I:%M %p %b %d %Y") unless datetime.nil?
  end
  
  def format_as_date(date)
    return date.strftime("%b %d %Y") unless date.nil?
  end
  
  def format_as_time(time)
    return time.strftime("%I:%M") unless time.nil?
  end
  
  # formats an address
  def format_as_address(m)
    html = m.address1
    html << "<br/>"
    html << m.address2 unless m.address2.blank?
    html << "<br/>" unless m.address2.blank?
    html << m.city
    html << ", "
    html << m.state
    html << ", "
    html << m.zip
    html << "<br/>"    
    return html.html_safe
  end
  
  # formats for list
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
  
  # format for a field
  def format_field(label, value, popover_text=nil)
 
    html = "<div class='row-fluid control-group'>"
    html << "<div class='span4 display-label'>"
    html << label
    html << "</div>"
    html << "<div class='span8 display-value'>"
    html << value.to_s unless value.nil?
    unless popover_text.nil?
      html << '&nbsp;'
      html << "<a href='#' class='info_icon' data-toggle='popover' title='Information' data-placement='top' data-content='" + popover_text + "'><i class='fa fa-info-sign'></i></a>"
    end
    html << "</div>"
    html << "</div>"
    
    return html.html_safe    
    
  end
 
end