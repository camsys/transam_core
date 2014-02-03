class UnlocksController < Devise::UnlocksController

  # determine which layout to use based on the current user state
  layout :layout_by_resource

  # Determine which layout to use based on the authorized state
  def layout_by_resource
    if user_signed_in?
      "application"
    else
      "unauthorized"
    end
  end       
 
end