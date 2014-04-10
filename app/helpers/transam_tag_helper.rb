module TransamTagHelper

  def loader_panel_tag(options={})
    html = "<div class='loader'><i class='fa fa-spinner fa-spin fa-2x'></div>"
    return html.html_safe
  end

  def image_thumbnail_tag(options={}, &block)

    # Check to see if there is any content in the block
    content = capture(&block)
    if content.nil?
      content = "<p>&nbsp;</p>"
    end

    html = "<li class='shadow thumbnail action-thumbnail "
    html << options[:class] unless options[:class].blank?
    html << "'>"
    html << "<div data-action-path='"
    html << options[:path]
    html << "'>"

    html << content

    html << "</div>"
    html << "</li>"

    return html.html_safe
  end

  def action_thumbnail_tag(options={}, &block)

    # Check to see if there is any content in the block
    content = capture(&block)
    if content.nil?
      content = "<p>&nbsp;</p>"
    end

    html = "<li class='thumbnail shadow action-thumbnail "
    html << options[:class] unless options[:class].blank?
    html << "'>"
    html << "<div data-action-path='"
    html << options[:path]
    html << "'>"
    html << "<div class='well well-small' style='margin-bottom:0px;height:125px;'>"
    html << "<div class='row'>"
    html << "<div class='col-md-4'>"
    html << "<i class='"
    html << options[:icon]
    html << " fa-4x' style='margin-top:5px;'></i>"
    html << "</div>"
    html << "<div class='col-md-8'>"
    html << "<h4 class='action-thumbnail-caption'>"
    html << options[:title]
    html << "</h4>"    
    html << "</div>"
    html << "</div>"
    html << "<div class='col-md-12 first-in-row' style='margin-top:5px;'>"

    html << content

    html << "</div>"
    html << "</div>"
    html << "</div>"
    html << "</li>"

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
