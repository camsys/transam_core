class NoticesController < OrganizationAwareController
  
  add_breadcrumb "Home", :root_path
  add_breadcrumb "Notices", :notices_path
  
  before_filter :get_notice, :except => [:index, :create, :new]
      
  # Session Variables
  INDEX_KEY_LIST_VAR        = "notice_list_cache_var"
      
  def index

    @notices = Notice.all.order(:display_datetime) 
      
    # cache the set of asset ids in case we need them later
    #cache_list(@notices, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @notices }
    end
  end
  
  def new

    add_breadcrumb "New"
    @notice = Notice.new

  end

  # @notice set in before_filter
  def reactivate
    add_breadcrumb @notice, notice_path(@notice)
    add_breadcrumb "Reactivate"

    # shift dates forward but maintain duration.  Set active
    duration = @notice.duration_in_hours
    @notice.display_datetime = DateTime.now.beginning_of_hour
    @notice.end_datetime = @notice.display_datetime.advance(:hours => duration)
    @notice.active = true

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
    
    add_breadcrumb @notice, notice_path(@notice)
    add_breadcrumb "Notice"

    respond_to do |format|
      if @notice.update_attributes(:active => false)
        notify_user(:notice, "Notice was successfully deactivated.")
        format.html { redirect_to notice_path(@notice) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit"}
        format.json { render :json => @notice.errors, :status => :unprocessable_entity }
      end
    end
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
      notify_user(:alert, 'Record not found!')
      redirect_to notices_url
      return
    end
    
  end
    
end
