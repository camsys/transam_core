module TransamTagHelper

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

  def loader_panel_tag(options={})

    msg = (options[:message] ||= "Loading...")
    spinner = (options[:spinner] ||= "spinner")
    size = (options[:size] ||= 3)
    html_class = (options[:html_class] ||= 'ajax-loader')
    html_message_class = (options[:html_message_class] ||= 'ajax-loader-message')
    "<div class='#{html_class} text-center'><i class='fa fa-spin fa-#{spinner} fa-#{size}x'></i><span class='#{html_message_class}'> #{msg}</span></div>".html_safe
  end

  def image_thumbnail_tag(options={}, &block)

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

    html << content

    html << "</div>"
    html << "</div>"

    html.html_safe
  end

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

  #
  #
  # Sub Navigation Tag Helpers
  #
  #
  def sub_nav_elem_tag(&block)

    content = capture(&block)
    html = "<li>"
    html << content
    html << "</li>"

    return html.html_safe
  end

  def sub_nav_tag(options={}, &block)

    # Check to see if there is any content in the block
    content = capture(&block)
    if content.nil?
      content = "<p>&nbsp;</p>"
    end

    html = "<div class='row "
    html << options[:class] unless options[:class].blank?
    html << "'>"
    html << "<div class='col-md-12'>"
    html << "<div class='navbar navbar-default' role='navigation'>"
    html << "<div class='container-fluid'>"
    html << "<ul class='nav navbar-nav'>"
    html << content
    html << "</ul>"
    html << "</div>"
    html << "</div>"
    html << "</div>"
    html << "</div>"

    return html.html_safe
  end

  def dialog_tag(dialog_name, options={}, &block)
    # Check to see if there is any content in the block
    content = capture(&block)
    if content.nil?
      content = "<p>&nbsp;</p>"
    end

    html = "<div class='panel panel-default "
    unless options[:class].blank?
      html << options[:class]
    end
    html << "'>"
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
