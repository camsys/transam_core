class ReportType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  has_many :reports

  def to_s
    name
  end

end
