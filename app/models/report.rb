class Report < ActiveRecord::Base

  # Enable auditing of this model type
  has_paper_trail
  
  # associations
  belongs_to :report_type
  
  #attr_accessible :active, :report_type_id, :name, :class_name, :view_name, :description, :show_in_nav
        
  # default scope
  default_scope { where(:active => true) }
      
  scope :show_in_nav, -> { where(:show_in_nav => true) }
  scope :show_in_dashboard, -> { where(:show_in_dashboard => true) }

end
