class ReportType < ActiveRecord::Base

  #attr_accessible :name, :description, :active

  # default scope
  default_scope { where(:active => true) }

  has_many :reports

  def to_s
    name
  end

end
