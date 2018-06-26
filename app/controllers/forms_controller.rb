class FormsController < OrganizationAwareController

  before_action :get_form, :only => [:show]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Forms", :forms_path

  # Lock down the controller
  authorize_resource only: [:index]

  #-----------------------------------------------------------------------------
  def index

    @forms = []
    Form.all.each do |form|
      if current_user.is_in_roles? form.role_names
        @forms << form
      end
    end

  end

  #-----------------------------------------------------------------------------
  # The show method for a form simply redirects the view
  # to the controller configured for the selected form type
  #-----------------------------------------------------------------------------
  def show

    path = eval("form_#{@form.controller}_url('#{@form.object_key}')")
    redirect_to path

  end

  #-----------------------------------------------------------------------------
  # Private Methods
  #-----------------------------------------------------------------------------
  private

  #-----------------------------------------------------------------------------
  # Returns the selected form
  #-----------------------------------------------------------------------------
  def get_form
    # load this report and create the form instance
    form = Form.find_by(:object_key => params[:id])
    # check that the current use is authorized to view the form
    unless form.nil?
      if current_user.is_in_roles? form.role_names
        @form = form
      end
    end
    if @form.nil?
      notify_user(:alert, "Can't find form.")
      redirect_to '/404'
      return
    end
  end
end
