class NoticesController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Notices", :notices_path

  before_action :get_notice, :except => [:index, :create, :new]

  # Protect controller methods using the cancan ability
  authorize_resource

  # Session Variables
  INDEX_KEY_LIST_VAR        = "notice_list_cache_var"

  def index

    if current_user.has_role? :admin
      @notices = Notice.all.order(:display_datetime)
    else
      @notices = Notice.visible.order(:display_datetime)
    end
    # cache the set of notices ids in case we need them later
    cache_list(@notices, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @notices }
    end
  end

  def show
    add_breadcrumb ActionController::Base.helpers.sanitize(@notice.subject)

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@notice, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : notice_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : notice_path(@next_record_key)

  end

  def new

    Rails.logger.debug "In notices#new"
    add_breadcrumb "New"
    @notice = Notice.new

  end

  # @notice set in before_action
  def reactivate
    add_breadcrumb @notice, notice_path(@notice)
    add_breadcrumb "Reactivate"

    # shift dates forward but maintain duration.  Set active
    duration = @notice.duration_in_hours
    @notice.display_datetime = DateTime.current.beginning_of_hour
    @notice.end_datetime = @notice.display_datetime.advance(:hours => duration)
    @notice.active = true
    @notice.save

    render "new"
  end

  def edit

    add_breadcrumb @notice, notice_path(@notice)
    add_breadcrumb "Update"

  end

  def create

    add_breadcrumb "New"
    @notice = Notice.new(form_params)

    respond_to do |format|
      if @notice.save
        notify_user(:notice, "Notice was successfully created.")
        format.html { redirect_to notices_url }
        format.json { render :json => @notice, :status => :created, :location => @notice }
      else
        format.html { render :action => "new" }
        format.json { render :json => @notice.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    add_breadcrumb @notice, notice_path(@notice)
    add_breadcrumb "Notice"

    respond_to do |format|
      if @notice.update_attributes(form_params)
        notify_user(:notice, "Notice was successfully updated.")
        format.html { redirect_to notices_url }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @notice.errors, :status => :unprocessable_entity }
      end
    end
  end

  def deactivate

    @notice.active = false
    @notice.save

    redirect_to :back

  end

  def destroy

    @notice.destroy
    notify_user(:notice, "Notice was successfully removed.")
    respond_to do |format|
      format.html { redirect_to notices_url }
      format.json { head :no_content }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:notice).permit(Notice.allowable_params)
  end

  def get_notice
    # See if it is our policy
    @notice = Notice.find_by_object_key(params[:id]) unless params[:id].nil?
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @notice.nil?
      redirect_to '/404'
      return
    end

  end

end
