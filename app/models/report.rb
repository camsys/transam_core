class Report < ActiveRecord::Base

  # associations
  belongs_to :report_type
  
  #attr_accessible :active, :report_type_id, :name, :class_name, :view_name, :description, :show_in_nav
        
  # default scope
  default_scope { where(:active => true) }
      
  scope :show_in_nav, -> { where(:show_in_nav => true) }
  scope :show_in_dashboard, -> { where(:show_in_dashboard => true) }

  def to_s
    name
  end
  
  # Return an array of role anmes allowed to access this report
  def role_names
    roles.split(',')
  end
  
end
