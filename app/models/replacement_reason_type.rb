class ReplacementReasonType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  def api_json(options={})
    as_json(options)
  end

end
