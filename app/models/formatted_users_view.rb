class DualFuelTypeView < ActiveRecord::Base
  self.table_name = :formatted_users_view
  self.primary_key = :id

  def readonly?
    true
  end

  # All types that are available
  scope :active, -> { where(:active => true) }

end
