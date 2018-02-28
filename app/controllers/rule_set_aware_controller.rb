class RuleSetAwareController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Policies", :rule_sets_path

  # set the @rule_set_class variable before any actions are invoked
  before_action :get_rule_set_class

  #before_action :set_rule_set, except: [:new, :create]

  def new
    @rule_set = @rule_set_type.class_name.constantize.new
  end

  def create
    @rule_set = @rule_set_type.class_name.constantize.new(rule_set_params)

    if @rule_set.save
      redirect_to rule_set_path(@rule_set)
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  # this method is to take some rule set data model and distribute by dup of each org in that data model's HABTM org relationship
  # override .dup at the model level if want to copy over any associations or other customizations
  # -------------------------------------------------
  # ASSUMPTIONS
  # --------------------------------------------------
  # make sure there is a variable set for the object being dupped - should be named similar to the controller name
  # .organizations exists
  # .organization exits and can be set
  # has an object key
  # assume that there's a distribute event in the state machine for the data object
  # assume data obj has parent variable

  def distribute
    # use the name of the controller that inherits from the rule set aware controller to determine the variable name of the object we're duping
    data_obj = eval("@#{params[:controller].singularize}")

    orgs = data_obj.try(:organizations) || []
    orgs.each do |org|
      new_data_obj = data_obj.dup
      new_data_obj.object_key = nil # assume always have an object_key
      new_data_obj.organization = org
      new_data_obj.parent = data_obj

      new_data_obj.save!
    end

    # fire workflow event
    params[:event] = 'distribute'
    fire_workflow_event

  end

  #-------------------------------------------------------------------------------
  # Used by all form controllers to update the form status as it goes thorugh
  # its workflows
  #-------------------------------------------------------------------------------
  def fire_workflow_event

    # use name of controller to get class
    klass = params[:controller].classify.constantize

    # Check that this is a valid event name for the state machines
    if klass.event_names.include? params[:event]
      event_name = params[:event]
      rule_set = klass.find_by(object_key: params[:id])

      puts rule_set.inspect

      if rule_set.fire_state_event(event_name)
        event = WorkflowEvent.new
        event.creator = current_user
        event.accountable = rule_set
        event.event_type = event_name
        event.save

        # if notification enabled, then send out
        # if @form.class.try(:workflow_notification_enabled?)
        #   @form.notify_event_by(current_user, event_name)
        # end
      else
        notify_user(:alert, "Could not #{event_name.humanize} form #{rule_set}")
      end
    else
      notify_user(:alert, "#{params[:event_name]} is not a valid event for a #{klass.class.name}")
    end

    redirect_to :back

  end




    #-------------------------------------------------------------------------------
  protected
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    # Returns the selected form
    #-------------------------------------------------------------------------------
  def get_rule_set_class
    # load this report and create the report instance
    rule_set = RuleSet.find_by(:object_key => params[:rule_set_id]) unless params[:rule_set_id].blank?
    # check that the current use is authorized to view the report
    unless rule_set.nil?
      @rule_set_type = rule_set
      add_breadcrumb @rule_set_type, rule_set_path(@rule_set_type)
    end
    if @rule_set_type.nil?
      notify_user(:alert, "Can't find rule set.")
      redirect_to '/404'
      return
    end
  end

  private

  def rule_set_params
    params.require(@rule_set_type.class_name.underscore.to_sym).permit(@rule_set_type.class_name.constantize.allowable_params)
  end
end
