class AssetEventType < ActiveRecord::Base
      
  #attr_accessible :name, :description, :active
  #attr_accessible :class_name, :form_name
  
  # default scope
  default_scope { where(:active => true) }

  def to_s
    name
  end
       
end
