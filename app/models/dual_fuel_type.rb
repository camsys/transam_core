class DualFuelType < ActiveRecord::Base

  belongs_to :primary_fuel_type, :class_name => "FuelType"
  belongs_to :secondary_fuel_type, :class_name => "FuelType"


  validates :primary_fuel_type,     :presence => true
  validates :secondary_fuel_type,   :presence => true

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    "#{primary_fuel_type.name}-#{secondary_fuel_type.name}"
  end

end
