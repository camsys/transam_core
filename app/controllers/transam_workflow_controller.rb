class TransamWorkflowController < ApplicationController


  def fire_workflow_event
    event_proxy = TransamWorkflowModelProxy.new(include_updates: 0, event_name: params[:event_name], global_ids: params[:global_id])

    process_workflow_event(event_proxy)

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.js { render partial: "#{event_proxy.class_name.tabelize}/fire_workflow_events" }
    end
  end

  # this method would change the state of a single or many model objects (starting an the same from_start)
  # and if necessary, after doing some field/info updates to the model objects
  def fire_workflow_events
    params[:transam_workflow_model_proxy][:global_ids] = params[:transam_workflow_model_proxy][:global_ids].split(',')
    event_proxy = TransamWorkflowModelProxy.new(workflow_params)

    process_workflow_event(event_proxy)

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.js { render partial: "#{event_proxy.class_name.tabelize}/fire_workflow_events" }
    end
  end

  protected

  def workflow_params

    params.require(:transam_workflow_model_proxy).permit(TransamWorkflowModelProxy.allowable_params)
  end

  def workflow_model_params(class_name)
    # if defined at the class or the instance level
    params.require(:transam_workflow_model_proxy).permit(class_name.constantize.try(:allowable_params) || class_name.constantize.new.allowable_params)
  end

  def process_workflow_event(event_proxy)
    if !event_proxy.model_objs.empty? && event_proxy.event_name.present?
      Rails.logger.debug "fire_workflow_events event_name: #{event_proxy.event_name} for #{event_proxy.model_objs.count} instance(s)."

      # Process each order sequentially
      event_proxy.model_objs.each do |model_obj|
        if model_obj.class.event_names.include? event_proxy.event_name
          if event_proxy.include_updates.to_i > 0 && model_obj.machine.send("can_#{event_proxy.event_name}?")
            model_obj.update!(workflow_model_params(event_proxy.class_name))
          end
          if model_obj.machine.fire_state_event(event_proxy.event_name)
            WorkflowEvent.create(creator: current_user, accountable: model_obj, event_type: event_proxy.event_name)
          end
        end
      end
    end
  end

end
