class FiscalYearInput < SimpleForm::Inputs::Base
  def input
    field_name = "#{@builder.object_name}_#{attribute_name}"

    out = ActiveSupport::SafeBuffer.new
    out << @builder.hidden_field(attribute_name).html_safe
    out << "<div class='input-group' style='max-width:140px;'>".html_safe
    out << "<span class='input-group-addon'>FY </span>".html_safe
    out << template.number_field_tag(:"#{attribute_name}_input", object.send(attribute_name),input_html_options.merge({for: field_name, min: 0, max: 99})).html_safe
    out << "<span class='input-group-addon' for='#{field_name}'> - XX</span>".html_safe
    out << "</div>".html_safe
  end

  def label_target
    :"#{attribute_name}_input_start"
  end


  def input_html_classes
    super.push('form-control')
  end

end