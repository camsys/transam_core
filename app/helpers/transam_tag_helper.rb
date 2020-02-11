module TransamTagHelper

  # returns html for a popover
  def popover_tag(text, options={})

    tag_class = (options[:class] ||= "transam-popover")
    placement = (options[:placement] ||= "auto")

    html = "<a tabindex='0' class='#{tag_class}' role='button' data-placement='#{placement}' data-container='body' data-html='true' data-toggle='popover' data-trigger='focus'"
    html << " title='#{options[:title]}'" unless options[:title].blank?
    html << " data-content='#{options[:content]}'>"
    if options[:icon].present?
      html << "<i class='fa #{options[:icon]}'>"
    end
    html << text unless text.blank?
    if options[:icon].present?
      html << "</i>"
    end
    html << "</a>"
    html.html_safe
  end

  # returns html for a spinner panel
  def loader_panel_tag(options={})

    msg = (options[:message] ||= "Loading...")
    spinner = (options[:spinner] ||= "spinner")
    size = (options[:size] ||= 3)
    html_class = (options[:html_class] ||= 'ajax-loader')
    html_message_class = (options[:html_message_class] ||= 'ajax-loader-message')
    "<div class='#{html_class} text-center'><i class='fa fa-spin fa-#{spinner} fa-#{size}x'></i><span class='#{html_message_class}'> #{msg}</span></div>".html_safe
  end

  # returns html for the old style action "cards"
  def action_thumbnail_tag(options={}, &block)

    # Check to see if there is any content in the block
    content = capture(&block)
    if content.nil?
      content = "<p>&nbsp;</p>"
    end

    html = "<div class='"
    html << options[:class] unless options[:class].blank?
    html << "'>"
    html << "<div class='thumbnail action-thumbnail' data-action-path='"
    html << options[:path]
    html << "'>"

    html << "<div class='well well-small thumbnail-content' style='padding:10px;margin-bottom:0;'>"

    html << "<div class='caption' style='padding:0;'>"
    html << "<h3 style='margin-top:0;text-overflow:ellipsis;white-space:nowrap;overflow:hidden;'>"
    html << "<i class='"
    html << options[:icon]
    html << " fa-2x'></i> "
    html << options[:title]
    html << "</h3>"
    html << "</div>"

    html << content

    html << "</div>"
    html << "</div>"
    html << "</div>"


    return html.html_safe
  end

  # returns html for nav tabs that include a count of items under the tab 
  def nav_tab_count_tag(href, title, count)
    engine = Haml::Engine.new("
%li
  %a{:href => '#{href}', :data =>{:toggle => 'tab'}}
    %span.nowrap
      #{title}
      %span.badge= #{count}
")
    return engine.render.html_safe
  end

  #
  # generic method for updating fields of any model through xeditable
  # IF YOU UPDATE THIS METHOD, update the asset field tag version as well
  #
  def editable_field_tag(model_obj, field, label=nil, model_name: nil, required: true, type: 'text', min: nil, max: nil, suffix: '', inputclass: '', url: '')
    asset = model_obj.is_a?(Array) ? model_obj.last : model_obj

    if type == 'boolean'
      return editable_association_tag(asset, field, label,
                                            [[1, 'Yes'],[0, 'No']],
                                            include_blank: !required, current_value: asset.send(field) ? 1 : 0, suffix: suffix, inputclass: '')
    end
    extras = ''
    extras += ", min: #{min}" if min
    extras += ", max: #{max}" if max
    classes = ' '
    classes += 'required ' if required
    # classes += 'datepicker ' if type == 'date'
    value = escape_javascript(asset.send(field).to_s)
    case type
      when 'date'
        type = 'combodate'
        classes += 'combodate'
        value = format_as_date(Date.parse(value)) unless value.blank?
      # extras += ", format: 'MM/DD/YYYY', viewformat: 'MM/DD/YYYY'"
      when 'currency'
        type = 'number'
        classes += 'currency-number'
      when 'textarea'
        value = asset.send(field).to_s.gsub(/\r\n|\r|\n/, "<br />")
    end

    # Escape for HAML
    label = label.gsub('%','\%') if label

    if url
      asset_path = url
    elsif model_name.nil? || model_obj.class.to_s == model_name
      asset_path = polymorphic_path(model_obj)
    else
      asset_path = polymorphic_path(model_obj.send(model_name.underscore))
    end

    engine = Haml::Engine.new("
##{field}_group.form-group
  %label.control-label{class: '#{classes}'}
    #{label || field.to_s.titleize}
  .display-value
    %a.editable-field{href:'#', id: '#{field}', class: '#{classes}', data: {inputclass: '#{inputclass}', emptytext: ' - ', name: '#{(model_name || asset.class.base_class.name).underscore}[#{field}]', type: '#{type}', placeholder: '#{required ? 'Required' : ''}', url: '#{asset_path}'#{extras}}}
      \\#{value}
                              #{suffix}
                              ")
    return engine.render.html_safe
  end

  #
  # generic method for updating associations of any model through xeditable
  # IF YOU UPDATE THIS METHOD, update the asset association tag version as well
  #
  def editable_association_tag(model_obj, field, label=nil, collection=nil, model_name: nil, current_method: nil, include_blank: false, current_value: nil, type: 'select', url: nil, suffix: '_id')

    asset = model_obj.is_a?(Array) ? model_obj.last : model_obj

    # value = current_value || (collection || url ? asset.send(current_method || field).to_s : asset.send(current_method || "#{field.to_s}_id").to_s)
    field_name = current_method || "#{field.to_s.singularize}#{suffix}"
    value = current_value || asset.send(current_method || field_name).to_s
    unless collection || url
      klass = asset.association(field).reflection.class_name.constantize
      collection = klass.active.collect{|a| [a.id, a.to_s]}

    end
    unless url
      # The source will wind up being parsed twice by X-editable, so embedded apostrophes
      # have to be doubly escaped.
      source = include_blank ? "{value: '', text: ''}," : ''
      source += collection.map{|pair| "{value: '#{pair[0]}', text: '#{pair[1].to_s.gsub("'"){"\\\\'"}}'}"}.join(',')
    end

    if model_name.nil? || model_obj.class.to_s == model_name
      asset_path = polymorphic_path(model_obj)
    else
      asset_path = polymorphic_path(model_obj.send(model_name.underscore))
    end

    engine = Haml::Engine.new("
##{field}_group.form-group
  %label.control-label
    #{label || field.to_s.titleize}
  .display-value
    %a.editable-field{href:'#', id: '#{field}', data: {emptytext: ' - ', name: '#{(model_name || asset.class.base_class.name).underscore}[#{field_name}]', value: '#{value}', type: '#{type}', url: '#{asset_path}', source: \"#{url || "[#{source}]"}\", sourceCache: '#{url.nil?}'}}
")
    return engine.render.html_safe
  end

  #
  # updating asset fields through xeditable
  # IF YOU UPDATE THIS METHOD, update the generic field tag version as well
  #
  def editable_asset_field_tag(asset, field, label=nil, required: true, type: 'text', min: nil, max: nil, suffix: '', inputclass: '', current_value: nil)
    if type == 'boolean'
      return editable_asset_association_tag(asset, field, label,
                                            [[1, 'Yes'],[0, 'No']],
                                            include_blank: !required, current_value: @asset.send(field) ? 1 : 0, suffix: suffix, inputclass: inputclass)
    end
    extras = ''
    extras += ", min: #{min}" if min
    extras += ", max: #{max}" if max
    classes = ' '
    classes += 'required ' if required
    # classes += 'datepicker ' if type == 'date'
    value = current_value || escape_javascript(asset.send(field).to_s)
    case type
    when 'date'
      type = 'combodate'
      classes += 'combodate'
      value = format_as_date(Date.parse(value)) unless value.blank?
      # extras += ", format: 'MM/DD/YYYY', viewformat: 'MM/DD/YYYY'"
    when 'currency'
      type = 'number'
      classes += 'currency-number'
    when 'textarea'
      value = asset.send(field).to_s.gsub(/\r\n|\r|\n/, "<br />")
    end
    
    # Escape for HAML
    label = label.gsub('%','\%') if label
    engine = Haml::Engine.new("
##{field}_group.form-group
  %label.control-label{class: '#{classes}'}
    #{label || field.to_s.titleize}
  .display-value
    %a.editable-field{href:'#', id: '#{field}', class: '#{classes}', data: {inputclass: '#{inputclass}', emptytext: ' - ', name: 'asset[#{field}]', type: '#{type}', placeholder: '#{required ? 'Required' : ''}', url: '#{asset_path(asset)}'#{extras}}}
      \\#{value}
    #{suffix}
")
    return engine.render.html_safe
  end

  #
  # updating asset associations through xeditable
  # IF YOU UPDATE THIS METHOD, update the generic association tag version as well
  #
  def editable_asset_association_tag(asset, field, label=nil, collection=nil, current_method: nil, include_blank: false, current_value: nil, type: 'select', url: nil, suffix: '_id', inputclass: '', include_other: false, display_text: nil)
    # value = current_value || (collection || url ? asset.send(current_method || field).to_s : asset.send(current_method || "#{field.to_s}_id").to_s)
    field_name = current_method || "#{field.to_s.singularize}#{suffix}"
    value = current_value || asset.send(current_method || field_name).to_s
    unless collection || url
      klass = asset.association(field).reflection.class_name.constantize
      collection = klass.active.collect{|a| [a.id, a.to_s]}
                                                 
    end

    # Tags with url data sources will sometimes display as blank due to an ajax race condition.
    # Here, we force in display text containing the field's to_string implementation when the data source is from a url.
    display_text = display_text || ""
    if url
      display_text = display_text.blank? ? (suffix == '_ids' ? asset.send(field.to_s.pluralize).map{|x| x.to_s}.join("<br>").html_safe : asset.send(field.to_s).to_s) : display_text
    else
      # The source will wind up being parsed twice by X-editable, so embedded apostrophes
      # have to be doubly escaped.
      source = include_blank ? "{value: '', text: ''}," : ''
      source += collection.map{|pair| "{value: '#{pair[0]}', text: '#{pair[1].to_s.gsub("'"){"\\\\'"}}'}"}.join(',')
      if include_other
        source += "," unless source[-1] == ","
        source += "{value: '#{TransamAsset::DEFAULT_OTHER_ID}', text: 'Other'}" if include_other
      end
    end    
    engine = Haml::Engine.new("
##{field}_group.form-group
  %label.control-label
    #{label || field.to_s.titleize}
  .display-value
    %a.editable-field{href:'#', id: '#{field}', data: {inputclass: '#{inputclass}', emptytext: ' - ', name: 'asset[#{field_name}]', value: '#{value}', type: '#{type}', url: '#{asset_path(asset)}', source: \"#{url || "[#{source}]"}\", sourceCache: '#{url.nil?}'}} #{display_text}
")
    return engine.render.html_safe
  end

  # returns html for a panel comprising a subcomponent of a form
  def dialog_tag(dialog_name, options={}, &block)
    # Check to see if there is any content in the block
    content = capture(&block)
    if content.nil?
      content = "<p>&nbsp;</p>"
    end

    id = options[:id]
    id_str = id ? "id='#{id}'" : "id='#{format_as_id(dialog_name)}_dialog'"
    html = "<div class='panel panel-default #{options[:class]}' #{id_str}>"
    html << "<div class='panel-heading'>"
    html << "<h3 class='panel-title'>"
    unless options[:icon].blank?
      html << "<i class='"
      html << options[:icon]
      html << "'></i> "
    end
    html << dialog_name
    html << "</h3>"
    unless options[:link_path].blank?
      html << "<div style='float:right;position:relative;top:-15px;'>"
      html << link_to(options[:link_text], options[:link_path], :class => "")
      html << "</div>"
    end
    html << "</div>"
    html << "<div class='panel-body'>"
    html << content
    html << "</div>"
    html << "</div>"
    return html.html_safe
  end

end
