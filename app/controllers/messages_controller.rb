class MessagesController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  before_action :set_message, :only => [:show, :edit, :update, :destroy, :tag, :reply]
  before_filter :check_for_cancel, :only => [:create]

  # Enumerables for message filters
  MESSAGE_TYPE_NEW    = 1
  MESSAGE_TYPE_OLD    = 2
  MESSAGE_TYPE_SENT   = 3

  SESSION_FILTER_TYPE_VAR = 'messages_filter_type'

  def index

    add_breadcrumb "My Messages", user_messages_path(current_user)

    # Get the filter
    @filter = get_filter_type(SESSION_FILTER_TYPE_VAR)
    #puts @filter

    # Start to set up the query
    conditions  = []
    values      = []

    # New messages must be for the current user
    conditions << 'to_user_id = ?'
    values << current_user.id

    # Get the messages
    @messages = Message.where(conditions.join(' AND '), *values).order("created_at DESC")
    @all_messages = @messages.where('opened_at IS NOT NULL')
    @new_messages = @messages.where('opened_at IS NULL')
    @flagged_messages = current_user.messages
    @sent_messages = Message.where(:user_id => current_user.id).order("created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @messages }
    end
  end

  # Tags the message for the user or removes it if the message
  # is already tagged. called by ajax so no response is rendered
  def tag

    if @message.tagged? current_user
      @message.users.delete current_user
    else
      @message.tag current_user
    end

    # No response needed
    render :nothing => true

  end

  def show

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @message.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(user_messages_url(current_user))
      return
    end

    add_breadcrumb "My Messages", user_messages_path(current_user)
    add_breadcrumb @message.subject, user_message_path(current_user, @message)

    @response = Message.new
    @response.organization = @organization
    @response.user = current_user
    @response.priority_type = @message.priority_type

    @page_title = 'Message'

    # Mark this message as opened if not opened previously
    if @message.opened_at.nil?
      @message.opened_at = Time.current
      @message.save
    end

    respond_to do |format|
      format.js # show.html.erb
      format.html # show.html.erb
      format.json { render :json => @message }
    end
  end

  def new

    @page_title = 'New Message'

    add_breadcrumb "My Messages", user_messages_path(current_user)
    add_breadcrumb "New"

    @message_proxy = MessageProxy.new

    @message_proxy.priority_type_id = PriorityType.default.id
    @message_proxy.to_user_ids << User.find_by_object_key(params[:to_user]).id unless params[:to_user].nil?
    @message_proxy.available_agencies = (@organization_list + current_user.organization_ids).uniq
    @message_proxy.subject = params[:subject] unless params[:subject].nil?
    @message_proxy.body    = params[:body] unless params[:body].nil?

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create

    add_breadcrumb "My Messages", user_messages_path(current_user)
    add_breadcrumb "New"

    @message_proxy = MessageProxy.new(message_proxy_form_params)
    Rails.logger.debug @message_proxy.inspect

    respond_to do |format|
      if @message_proxy.valid?
        priority = PriorityType.find(@message_proxy.priority_type_id)
        send_count = 0

        if @message_proxy.send_to_group == '1'
          org_list = []
          @message_proxy.group_agencys.uniq.each {|x| org_list << x unless x.blank?}
          # Sending to a group
          selected_users = User.where(:active => true)
          # Select agencies if provided
          selected_users = selected_users.where(:organization_id => org_list) unless org_list.empty?
          # Select roles if provided
          @message_proxy.group_roles.each do |role_id|
            selected_users = selected_users.with_role(Role.find(role_id).name) unless role_id.blank?
          end
          selected_users.each do |user|
            msg = Message.new
            msg.user = current_user
            msg.organization = @organization
            msg.to_user = user
            msg.subject = @message_proxy.subject
            msg.body = @message_proxy.body
            msg.priority_type = priority
            msg.save
            send_count += 1
          end
        else
          # Sending to individual users
          @message_proxy.to_user_ids.each do |user_id|
            unless user_id.blank?
              msg = Message.new
              msg.user = current_user
              msg.organization = @organization
              msg.to_user = User.find(user_id)
              msg.subject = @message_proxy.subject
              msg.body = @message_proxy.body
              msg.priority_type = priority
              msg.save
              send_count += 1
            end
          end
        end
        notify_user(:notice, "#{view_context.pluralize( send_count, 'Messages')} successfully sent.")
        format.html { redirect_to user_messages_url(current_user) }
      else
        Rails.logger.debug @message_proxy.errors
        @message_proxy.available_agencies = (@organization_list + current_user.organization_ids).uniq
        format.html { render :action => "new" }
      end
    end
  end

  # The user has posted a reply to an existing message
  def reply

    # old message is set from the filter
    @new_message = Message.new(form_params)
    @new_message.organization = @organization
    @new_message.user = current_user
    @new_message.priority_type = @message.priority_type
    @new_message.subject = 'Re: ' +  @message.subject
    @new_message.to_user = @message.to_user

    respond_to do |format|
      if @new_message.save
        notify_user(:notice, "Reply was successfully sent.")

        @message.responses << @new_message

        format.html { redirect_to user_messages_url(current_user) }
        format.json { render :json => @new_message, :status => :created }
      else
        format.html { render :action => "new" }
        format.json { render :json => @new_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # returns the filter type for the current controller and sets the session variable
  # to store any change in fitler type for the controller
  def get_filter_type(session_var)
    filter_type = params[:filter].nil? ? session[session_var].to_i : params[:filter].to_i
    if filter_type.nil?
      filter_type = MESSAGE_TYPE_NEW
    end
    # remember the view type in the session
    session[session_var] = filter_type
    return filter_type
  end

  def check_for_cancel
    unless params[:cancel].blank?
      # check that the user has access to this agency
      redirect_to(user_messages_url(current_user))
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:message).permit(Message.allowable_params)
  end

  def message_proxy_form_params
    params.require(:message_proxy).permit(MessageProxy.allowable_params)
  end

  # Callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find_by_object_key(params[:id]) unless params[:id].nil?
  end

end
