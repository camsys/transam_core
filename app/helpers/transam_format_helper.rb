module TransamFormatHelper
        
  # formats a URL as a link
  def format_as_url(url, target = '_blank')
    link_to(url, url, :target => target)
  end      
  
  # truncates any decimals and returns the number as currency
  def format_as_currency(val)
    number_to_currency(val.to_i, :precision => 0)
  end

  # if the value is a number it is formatted as a decimal or integer
  # otherwise we assume it is a string and is returned
  def format_as_general(val, precision = 2)
    begin
      Float(val)
      number_with_precision(val, :precision => precision, :delimiter => ",")
    rescue
      val      
    end
  end

  # truncates any decimals and returns the number as currency
  def format_as_integer(val)
    format_as_decimal(val, 0)
  end

  # returns a number as a decimal
  def format_as_decimal(val, precision = 2)
    number_with_precision(val, :precision => precision, :delimiter => ",")
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
    html = "<ul class='list-unstyled'>"
    coll.each do |e|
      html << "<li>"
      html << e.to_s
      html << "</li>"
    end
    html << "</ul>"
    html.html_safe
  end    

  # formats a boolean field using a check if the value is true
  def format_as_boolean(val)
    if val
      return "<i class='fa fa-check fa-fw'></i>".html_safe
    end
  end
  # formats a boolean field as Yes or No
  def format_as_yes_no(val)
    if val
      return "Yes"
    else
      return "No"
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
    
  # format for a field
  def format_field(label, value, popover_text=nil)
 
    html = "<div class='row control-group'>"
    html << "<div class='col-xs-4 display-label'>"
    html << label
    html << "</div>"
    html << "<div class='col-xs-8 display-value'>"
    html << value.to_s unless value.nil?
    unless popover_text.nil?
      html << "<i class='fa fa-info-circle info-icon' data-toggle='popover' data-trigger='hover' title='Information' data-placement='right' data-content='#{popover_text}'></i>"
    end
    html << "</div>"
    html << "</div>"
    
    return html.html_safe    
    
  end
 
end