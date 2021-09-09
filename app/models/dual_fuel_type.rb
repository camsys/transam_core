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

  #for bulk updates
  def self.schema_structure
    {
      "enum": DualFuelType.all.map { |dft| dft.to_s },
      "tuple": DualFuelType.all.map{ |x| {"id": x.try(:id), "val": x.to_s} },
      "type": "string",
      "title": "Dual Fuel Type"
    }
  end

end
