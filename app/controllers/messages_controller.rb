class MessagesController < OrganizationAwareController
  
  before_action :set_message, :only => [:show, :edit, :update, :destroy]  
  before_filter :check_for_cancel, :only => [:create] 

  SESSION_VIEW_TYPE_VAR = 'messages_subnav_view_type'
  
  # always use generic untyped organizations for this controller
  RENDER_TYPED_ORGANIZATIONS = false
  
  def render_typed_organizations
    RENDER_TYPED_ORGANIZATIONS
  end
  
  def index

    @page_title = 'Messages'
    # Select messages for this user or ones that are for the agency as a whole
    @messages = Message.where("organization_id = ? AND thread_message_id IS NULL AND (to_user_id IS NULL OR to_user_id = ?)", @organization.id, current_user.id).order("created_at DESC")
    
    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @messages }
    end
  end

  def show

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @message.nil?
      redirect_to(user_messages_url(current_user), :flash => { :alert => 'Record not found!'})
      return
    end

    @response = Message.new
    @response.organization = @organization
    @response.user = current_user
    @response.priority_type = @message.priority_type
 
    @page_title = 'Message'
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @message }
    end
  end

  def new

    @page_title = 'New Message'

    @message = Message.new
    @message.organization = @organization
    @message.user = current_user
    @message.priority_type = PriorityType.default

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @message }
    end
  end

  def create

    @message = Message.new(form_params)
    @message.organization = @organization
    @message.user = current_user
    
    # See if we got a message id posted, if so then the post is a response
    if params[:message_id]
      parent_message = @organization.messages.find(params[:message_id])
      @message.priority_type_id = parent_message.priority_type_id
      @message.subject = 'Re: ' + parent_message.subject
      @message.to_user_id = parent_message.to_user_id.nil? ? nil : parent_message.user_id
      @message.thread = parent_message
      parent_message.responses << @message
    end

    respond_to do |format|
      if @message.save
        format.html { redirect_to user_messages_url(current_user), :notice => "Message was successfully created." }
        format.json { render :json => @message, :status => :created }
      else
        format.html { render :action => "new" }
        format.json { render :json => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  def check_for_cancel 
    unless params[:cancel].blank?
      # check that the user has access to this agency
      redirect_to(user_messages_url(current_user))
    end
  end
  
  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:message).permit(message_allowable_params)
  end
  
  # Callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find_by_object_key(params[:id]) unless params[:id].nil?
  end
  
end
