module TransamFormatHelper

  # Include the fiscal year mixin
  include FiscalYear

  #-----------------------------------------------------------------------------
  # Formats a text field
  #-----------------------------------------------------------------------------
  def format_as_text(val, sanitize=false)
    simple_format(val, {}, :sanitize => sanitize)
  end

  # Formats a user name and provides message link and optional messaging options
  # available via the options hash
  def format_as_message_link(user, options = {})
    html = ''
    unless user.blank?
      options[:to_user] = user
      options[:subject] = options[:subject] || ''
      options[:body] = options[:body] || ''
      message_url = new_user_message_path(current_user, options)
      html = "<a href='#{message_url}'>#{user.email}"
      html << '&nbsp;'
      html << "<i class = 'fa fa-envelope'></i>"
      html << "</a>"
    end
    html.html_safe
  end


  # Formats a user name and provides an optional (defaulted) message link and
  # messaging options
  def format_as_user_link(user, options = {})
    html = ''
    unless user.blank?
      options[:to_user] = user
      options[:subject] = options[:subject] || ''
      options[:body] = options[:body] || ''
      user_url = user_path(user)
      html = "<a href='#{user_url}'>#{user}</a>"
      from_user = options[:from_user]
      if from_user.present?
        message_url = new_user_message_path(from_user, options)
        html << '&nbsp;'
        html << "<span class = 'message-link'>"
        html << "<a href='#{message_url}'>"
        html << "<i class = 'fa fa-envelope'></i>"
        html << "</a>"
        html << "</span>"
      end
    end
    html.html_safe
  end

  # Formats a quantity
  def format_as_quantity(count, unit_type = 'unit')
    unless unit_type.blank?
      "#{format_as_integer(count)} #{unit_type}"
    else
      "#{count}"
    end
  end

  # formats an assets list of asset groups with remove option
  def format_asset_groups(asset, style = 'info')
    html = ""
    asset.asset_groups.each do |grp|
      html << "<span class='label label-#{style}'>"
      html << grp.code
      html << "<span data-role='remove' data-action-path='#{remove_from_group_inventory_path(asset, :asset_group => grp)}'></span>"
      html << "</span>"
    end
    html.html_safe
  end

  # formats a list of labels/tags. By default labels are displayed
  # using label-info but can be controlled using the optional style param
  def format_as_labels(coll, style = 'info')
    html = ''
    coll.each do |e|
      if e.respond_to? :code
        txt = e.code
      else
        txt = e.to_s
      end
      html << "<span class='label label-#{style}'>"
      html << txt
      html << "</span>"
    end
    html.html_safe
  end

  # formats an element as a label. By default labels are displayed
  # using label-info but can be controlled using the optional style param
  def format_as_label(elem, style = 'info')
    html = "<span class='label label-#{style}'>"
    html << elem.to_s
    html << "</span>"
    html.html_safe
  end

  # formats a year value as a fiscal year string 'FY XX-YY'
  def format_as_fiscal_year(val)
    fiscal_year(val) unless val.nil?
  end

  # formats a URL as a link
  def format_as_url(url, target = '_blank')
    link_to(url, url, :target => target)
  end

  # if no precision is set this truncates any decimals and returns the number as currency
  def format_as_currency(val, precision = 0)
    val ||= 0
    if precision == 0
      if val < 0
        val = val - 0.5
      else
        val = val + 0.5
      end
      number_to_currency(val.to_i, :precision => 0)
    else
      number_to_currency(val, :precision => precision)
    end
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

  # formats a boolean field using a checkbox if the value is true
  def format_as_checkbox(val, text_class='text-default')
    if val
      return "<i class='fa fa-check-square-o #{text_class}'></i>".html_safe
    else
      return "<i class='fa fa-square-o #{text_class}'></i>".html_safe
    end
  end

  # formats a boolean field using a flag if the value is true
  def format_as_boolean(val, icon="fa-check", text_class='text-default')
    if val
      return "<i class='fa #{icon} #{text_class}'></i>".html_safe
    else
      return "<i class='fa #{icon} #{text_class}' style = 'visibility: hidden;'></i>".html_safe
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

  # Formats a date as a day date eg Mon 24 Oct
  def format_as_day_date(date)
    date.strftime("%a %d %b") unless date.nil?
  end

  # formats a date/time as a distance in words. e.g. 6 days ago
  def format_as_date_time_distance(datetime)
    dist = distance_of_time_in_words_to_now(datetime)
    if Time.current > datetime
      dist = dist + " ago"
    end
    return dist
  end

  # Standard formats for dates and times
  def format_as_date_time(datetime, compact=true)
    if compact
      datetime.strftime("%I:%M %p %m/%d/%Y") unless datetime.nil?
    else
      datetime.strftime("%I:%M %p %b %d %Y") unless datetime.nil?
    end
  end

  def format_as_date(date, compact=true)
    if compact
      date.strftime("%m/%d/%Y") unless (date.nil? || date.year == 1)
    else
      date.strftime("%b %d %Y") unless (date.nil? || date.year == 1)
    end
  end

  def format_as_time(time)
    return time.strftime("%I:%M %p") unless time.nil?
  end

  def format_as_military_time(time)
    return time.strftime("%H:%M") unless time.nil?
  end

  def format_as_time_difference(s, show_seconds = false)
    return if s.blank?
    dhms = [60,60,24].reduce([s]) { |m,o| m.unshift(m.shift.divmod(o)).flatten }
    val = []
    val << "#{dhms[0]} days" unless dhms[0] == 0
    val << "#{dhms[1]}h" unless dhms[1] == 0
    val << "#{dhms[2]}m"
    val << "#{dhms[3]}s" if show_seconds
    val.join(' ')
  end

  # formats an address
  def format_as_address(m)
    full_address = []
    full_address << m.address1 unless m.address1.blank?
    full_address << m.address2 unless m.address2.blank?

    address3 = []
    address3 << m.city unless m.city.blank?
    address3 << m.state unless m.state.blank?
    address3 << m.zip unless m.zip.blank?
    address3 = address3.compact.join(', ')

    full_address << address3
    full_address = full_address.compact.join('<br/>')

    return full_address.html_safe
  end

  # format for a field
  def format_field(label, value, popover_text=nil, popover_iconcls=nil, popover_label=nil)

    html = "<div class='row control-group'>"
    html << "<div class='col-xs-5 display-label'>"
    html << label
    html << "</div>"
    html << "<div class='col-xs-7 display-value'>"
    html << value.to_s unless value.nil?
    unless popover_text.nil?
      popover_iconcls = 'fa fa-info-circle info-icon' unless popover_iconcls
      popover_label = label unless popover_label
      html << "<i class='#{popover_iconcls} info-icon' data-toggle='popover' data-trigger='hover' title='#{popover_label}' data-placement='right' data-content='#{popover_text}'></i>"
    end
    html << "</div>"
    html << "</div>"

    return html.html_safe

  end

  def format_using_format(val, format)
    case format
      when :currencyM
        number_to_currency(val, format: '%u%nM', negative_format: '(%u%nM)')
      when :currency
        format_as_currency(val)
      when :fiscal_year
        format_as_fiscal_year(val.to_i) unless val.nil?
      when :integer
        format_as_integer(val)
      when :percent
        format_as_percentage(val)
      when :string
        val
      when :checkbox
        format_as_checkbox(val)
      when :boolean
        # Check for 1/0 val as well as true/false given direct query clause
        format_as_boolean(val == 0 ? false : val)
      when :list
        format_as_list(val)
      else
        # Note, current implementation uses rescue and is thus potentially inefficient.
        # Consider alterantives.
        format_as_general(val)
    end
  end

end
