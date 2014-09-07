class AssetSubtype < ActiveRecord::Base

  # Associations
  belongs_to :asset_type

  # Validations
  validates :asset_type, presence: true

  #attr_accessible :name, :description, :active, :size
  #attr_accessible :asset_type_id
        
  # default scope
  default_scope { where(:active => true) }

  def full_name
    "#{name} - #{description}"
  end      

  def to_s
    name
  end
                   
end
      
