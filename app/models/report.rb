class Report < ActiveRecord::Base

  # associations
  belongs_to :report_type


  # default scope
  #default_scope { where(:active => true) }

  scope :active, -> { where(:active => true) }
  scope :show_in_nav, -> { where(:active => true, :show_in_nav => true) }
  scope :show_in_dashboard, -> { where(:active => true, :show_in_dashboard => true) }

  def to_s
    name
  end

  # Return an array of role names allowed to access this report
  def role_names
    roles.split(',')
  end

end
