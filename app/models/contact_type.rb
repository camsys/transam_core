class ContactType < ActiveRecord::Base

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------

  def to_s
    name
  end


end
