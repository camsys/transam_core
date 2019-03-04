class District < ActiveRecord::Base

  # Associations
  belongs_to :district_type

  validates :name,              :presence => true
  #validates :code,              :presence => true, :uniqueness => true
  validates :description,       :presence => true
  validates :district_type_id,  :presence => true

  # All types that are available
  scope :active, -> { where(:active => true) }

  default_scope { order(:district_type_id, :name) }

  DistrictType.active.each do |district_type|
    scope (district_type.name.parameterize(separator: '_')+'_districts').to_sym, -> { where(district_type: district_type) }
  end

  def to_s
    "#{name} (#{district_type})"
  end

  def self.search(text, exact = true)
    if exact
      x = where('name = ? OR code = ? OR description = ?', text, text, text).first
    else
      val = "%#{text}%"
      x = where('name LIKE ? OR code LIKE ? OR description LIKE ?', val, val, val).first
    end
    x
  end

end
