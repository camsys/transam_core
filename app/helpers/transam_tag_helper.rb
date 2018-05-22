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
