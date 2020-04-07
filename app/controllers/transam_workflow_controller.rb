class TransamWorkflowController < ApplicationController


  def fire_workflow_event
    if params[:transam_workflow_model_proxy]
      event_proxy = TransamWorkflowModelProxy.new(workflow_params)
    else
      model_obj = params[:class_name].constantize.find_by(object_key: params[:object_key])
      event_proxy = TransamWorkflowModelProxy.new(include_updates: 0, event_name: params[:event_name], global_ids: [model_obj.to_global_id])
    end


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
    if !event_proxy.model_objs.empty?

      if event_proxy.include_updates.to_i > 0
        workflow_model_params(event_proxy.class_name).keys.select{|k| k.to_s.include? 'date'}.each do |date_field|
          params[:transam_workflow_model_proxy][date_field.to_sym] = reformat_date(params[:transam_workflow_model_proxy][date_field.to_sym])
        end
      end

      # Process each order sequentially
      event_proxy.model_objs.each do |model_obj|

        model_obj.transaction do

          model_obj.update!(workflow_model_params(event_proxy.class_name)) if event_proxy.include_updates.to_i > 0

          if fire_state_event(model_obj,event_proxy)
            WorkflowEvent.create!(creator: current_user, accountable: model_obj, event_type: event_proxy.event_name)
          else
            raise ActiveRecord::Rollback
          end

        end
      end
    end
  end

  def fire_state_event(model_obj, event_proxy)
    success = false # set success of firing state event to false by default

    # check four cases
    # event name given, no state change
    # event name given, state change
    # to_state given, no state change
    # to_state given, state change

    if event_proxy.event_name.present? && (can? event_proxy.event_name.to_sym, model_obj) && (model_obj.class.event_names.include? event_proxy.event_name)
        if model_obj.class.event_transitions(event_proxy.event_name).map{|x| x.values.map(&:to_sym)}.flatten.include?(model_obj.state.to_sym)
          success = true
        else
          Rails.logger.debug "fire_workflow_events event_name: #{event_proxy.event_name} for #{model_obj}."
          success = model_obj.machine.fire_state_event(event_proxy.event_name)
      end
    elsif event_proxy.to_state.present?
      if model_obj.state == event_proxy.to_state
        success = true
      else
        event_name = model_obj.allowable_event(event_proxy.to_state)
        if (can? event_name.to_sym, model_obj) && (model_obj.class.event_names.include? event_name)
          Rails.logger.debug "fire_workflow_events event_name: #{event_name} for #{model_obj}."
          success = model_obj.machine.fire_state_event(event_name)
        end
      end
    end

    return success
  end

  def reformat_date(date_str)
    # See if it's already in iso8601 format first
    return date_str if date_str.match(/\A\d{4}-\d{2}-\d{2}\z/)

    Date.strptime(date_str, '%m/%d/%Y').strftime('%Y-%m-%d')
  end

end
