module TransamTagHelper
  
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
    html << " fa-4x' style='margin-top:5px;'></i>"
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
    html << "<div class='dialog-title-bar corner-top'>"
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