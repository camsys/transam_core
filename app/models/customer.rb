class Customer < ActiveRecord::Base

  #associations
  belongs_to  :license_type
  has_one     :license_holder, -> { where('license_holder = true')}, :class_name => 'Organization'
  has_many    :organizations

  #attr_accessible :license_type_id, :active

  # Allow selection of active instances
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

end
