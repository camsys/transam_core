class WeatherCode < ActiveRecord::Base

  # All codes that are available
  scope :active, -> { where(:active => true) }

  default_scope { order(:city) }

  def self.search(state, city)
    where('state = ? AND city = ?', state, city).first
  end

  def to_s
    city
  end

end
