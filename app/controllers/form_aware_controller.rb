#
# Abstract controller that is used as the base class
# for any concrete controllers that are based on a form
#
class FormAwareController < OrganizationAwareController
  # set the @form_class variable before any actions are invoked
  before_action :get_form_class

  protected

  # Returns the selected form
  def get_form_class
    # load this report and create the report instance
    form = Form.find_by(:object_key => params[:form_id]) unless params[:form_id].blank?
    # check that the current use is authorized to view the report
    unless form.nil?
      if current_user.is_in_roles? form.role_names
        @form_type = form
      end
    end
    if @form_type.nil?
      notify_user(:alert, "Can't find form.")
      redirect_to forms_url
      return
    end
  end

end
