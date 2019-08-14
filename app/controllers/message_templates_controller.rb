class MessageTemplatesController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb 'Client Admin Interface', :client_admin_path
  add_breadcrumb "Messages", :message_templates_path

  before_action :set_message_template, :only => [:edit, :update, :destroy]

  # Lock down the controller
  authorize_resource only: [:index, :edit, :update, :new, :create, :destroy]

  # Session Variables
  #INDEX_KEY_LIST_VAR          = "message_templates_list_cache_var"

  def index
    # Get the templates
    @message_templates = MessageTemplate.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @message_templates }
    end
  end

  def new
    add_breadcrumb "New"

    @message_template = MessageTemplate.new

    respond_to do |format|
      format.html 
    end
  end

  def create
    @message_template = MessageTemplate.new(form_params)

    respond_to do |format|
      if @message_template.save
        format.html { redirect_to message_templates_url }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    add_breadcrumb @message_template.name

    respond_to do |format|
      format.html 
    end

  end

  def update
    respond_to do |format|
      if @message_template.update_attributes(form_params)
        format.html { redirect_to message_templates_url }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @message_template.destroy
    respond_to do |format|
      notify_user(:notice, "Message Template #{@message_template.name} has been deleted.")
      format.html { redirect_to message_templates_url }
      format.json { head :no_content }
    end
  end

  def message_history
    @messages = Message.left_outer_joins(:message_template).joins(:user).order(created_at: :desc).all

    unless params[:search].blank?
      search_string = ['message_templates.name', 'message_templates.description', "users.first_name", "users.last_name", 'messages.subject', 'email_status'].map{|r| "#{r} LIKE '%#{params[:search]}%'"}.join(' OR ')

      # parse dates for searching
      search_string << " OR (DATE(messages.created_at) BETWEEN '#{Chronic.parse(params[:search], guess: :begin)}' AND '#{Chronic.parse(params[:search], guess: :end)}')"

      @messages = @messages.where(Arel.sql(search_string))
    end

    params[:sort] ||= 'created_at'

    sorting_string = "#{params[:sort]} #{params[:order]}"

    respond_to do |format|
      format.html
      format.js
      format.json {
        render :json => {
          :total => @messages.count,
          :rows =>  @messages.reorder(sorting_string).limit(params[:limit]).offset(params[:offset]).as_json
          }
        }
      format.xls do
        response.headers['Content-Disposition'] = "attachment; filename=message_history.xls"
      end
      format.xlsx do
        response.headers['Content-Disposition'] = "attachment; filename=message_history.xlsx"
      end
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
    params.require(:message_template).permit(MessageTemplate.allowable_params)
  end

  # Callbacks to share common setup or constraints between actions.
  def set_message_template
    @message_template = MessageTemplate.find_by_object_key(params[:id]) unless params[:id].nil?
    if @message_template.nil?
      redirect_to '/404'
      return
    end
  end

end
