class FileContentType < ActiveRecord::Base

  # default scope
  scope :active, -> { where(active: true) }

  def to_s
    name
  end

end
