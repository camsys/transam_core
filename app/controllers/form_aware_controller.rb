#-------------------------------------------------------------------------------
# FormAwareController
#
# Abstract controller that is used as the base class for any concrete controllers
# that are based on a form
#
#-------------------------------------------------------------------------------
class FormAwareController < OrganizationAwareController

  # set the @form_class variable before any actions are invoked
  before_action :get_form_class

  #-------------------------------------------------------------------------------
  # Used by all form controllers to update the form status as it goes thorugh
  # its workflows
  #-------------------------------------------------------------------------------
  def fire_workflow_event

    # Check that this is a valid event name for the state machines
    if @form.class.event_names.include? params[:event]
      event_name = params[:event]
      if @form.fire_state_event(event_name)
        event = WorkflowEvent.new
        event.creator = current_user
        event.accountable = @form
        event.event_type = event_name
        event.save

        # if notification enabled, then send out
        if @form.class.try(:workflow_notification_enabled?)
          @form.notify_event_by(current_user, event)
        end
      else
        notify_user(:alert, "Could not #{event_name.humanize} form #{@form}")
      end
    else
      notify_user(:alert, "#{params[:event_name]} is not a valid event for a #{@form.class.name}")
    end

    redirect_to :back

  end

  #-------------------------------------------------------------------------------
  protected
  #-------------------------------------------------------------------------------

  #-------------------------------------------------------------------------------
  # Returns the selected form
  #-------------------------------------------------------------------------------
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
      redirect_to '/404'
      return
    end
  end

end
