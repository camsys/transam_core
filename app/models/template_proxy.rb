
class TemplateProxy < Proxy

  # General state variables
 
  # Type of template to generate
  attr_accessor  :file_content_type
  
  # Type of asset to process
  attr_accessor    :asset_type
  
  # Basic validations. Just checking that the form is complete
  validates :file_content_type, :presence => true 

  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end
                
end
