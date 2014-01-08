#------------------------------------------------------------------------------
#
# Address
#
# Mixin that adds address properties to a model
#
#------------------------------------------------------------------------------
module Address
  extend ActiveSupport::Concern

  included do
    has_many :properties, :as=>:parent
  end

  # Instance methods  
  def full_address
    elems = []
    elems << address1 unless address1.blank?
    elems << address2 unless address2.blank?
    elems << city unless city.blank?
    elems << state unless state.blank?
    elems << zip unless zip.blank?
    elems.compact.join(', ')    
  end
  
end