class MessagesController < OrganizationAwareController
  
  add_breadcrumb "Home", :root_path
  
  before_action :set_message, :only => [:show, :edit, :update, :destroy]  
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
    # every query is bounded by the user's organization
    conditions << 'organization_id = ?'
    values << @organization.id
    
    if @filter == MESSAGE_TYPE_NEW
      @page_title = 'New Messages'
      # New messages must be for the current user
      conditions << 'to_user_id = ?'
      values << current_user.id
      # ad not have been previously opened
      conditions << 'opened_at IS NULL'
      
    elsif @filter == MESSAGE_TYPE_SENT
      
      @page_title = 'New Messages'
      # New messages must be from the current user    
      conditions << 'user_id = ?'
      values << current_user.id
 
    else
      # Already read messages
      @page_title = 'Messages'            
      # All others must be for the current user
      conditions << 'to_user_id = ?'
      values << current_user.id
      # and have been previously opened
      conditions << 'opened_at IS NOT NULL'
    end    
 
    # Get the messages
    @messages = Message.where(conditions.join(' AND '), *values).order("created_at DESC")
    
    #puts "Filter Val = '#{session[SESSION_FILTER_TYPE_VAR]}'"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @messages }
    end
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
      @message.opened_at = Time.now
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
    add_breadcrumb "New Message"

    @message = Message.new
    @message.organization = @organization
    @message.user = current_user
    @message.priority_type = PriorityType.default

    @message.to_user = User.find_by_object_key(params[:to_user]) unless params[:to_user].nil?
    @message.subject = params[:subject] unless params[:subject].nil?
    @message.body    = params[:body] unless params[:body].nil?

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @message }
    end
  end

  def create

    add_breadcrumb "My Messages", user_messages_path(current_user)
    add_breadcrumb "New Message"

    @message = Message.new(form_params)
    @message.organization = @organization
    @message.user = current_user
    
    # See if we got a message id posted, if so then the post is a response
    if params[:message_id]
      parent_message = @organization.messages.find(params[:message_id])
      @message.priority_type_id = parent_message.priority_type_id
      @message.subject = 'Re: ' + parent_message.subject
      @message.to_user_id = parent_message.to_user_id.nil? ? nil : parent_message.user_id
      #@message.thread = parent_message
      parent_message.responses << @message
    end

    respond_to do |format|
      if @message.save
        notify_user(:notice, "Message was successfully sent.")
        format.html { redirect_to user_messages_url(current_user) }
        format.json { render :json => @message, :status => :created }
      else
        format.html { render :action => "new" }
        format.json { render :json => @message.errors, :status => :unprocessable_entity }
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
    params.require(:message).permit(message_allowable_params)
  end
  
  # Callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find_by_object_key(params[:id]) unless params[:id].nil?
  end
  
end
