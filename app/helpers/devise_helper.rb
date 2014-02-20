module DeviseHelper
  def devise_error_messages!
    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    html = "<div class='alert alert-error alert-block'>"
    html << "<ul>"
    html << messages
    html << "</ul>"
    html << "</div>"
    html.html_safe
  end
  
end