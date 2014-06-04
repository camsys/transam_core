# The BootstrapBreadcrumbsBuilder is a Bootstrap compatible breadcrumb builder.
# It provides basic functionalities to render a breadcrumb navigation according to Bootstrap's conventions.
#
# BootstrapBreadcrumbsBuilder accepts a limited set of options:
# * separator: what should be displayed as a separator between elements
#
# You can use it with the :builder option on render_breadcrumbs:
#     <%= render_breadcrumbs :builder => ::BootstrapBreadcrumbsBuilder, :separator => "&raquo;" %>
#
# Note: You may need to adjust the autoload_paths in your config/application.rb file for rails to load this class:
#     config.autoload_paths += Dir["#{config.root}/lib/"]
#
class BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  NoBreadcrumbsPassed = Class.new(StandardError)

  def render
    regular_elements = @elements.dup
    active_element = regular_elements.pop #|| raise(NoBreadcrumbsPassed)

    @context.content_tag(:ol, class: 'breadcrumb') do
      regular_elements.collect do |element|
        render_regular_element(element)
      end.join.html_safe + render_active_element(active_element).html_safe
    end
  end

  def render_regular_element(element)
    @context.content_tag :li do
      @context.link_to(compute_name(element), compute_path(element), element.options)
    end
  end

  def render_active_element(element)
    @context.content_tag :li, class: 'active' do
      compute_name(element) unless element.blank?
    end
  end
end