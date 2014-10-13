class NoticesController < OrganizationAwareController
  
  add_breadcrumb "Home", :root_path
  add_breadcrumb "Notices", :notices_path
  
  before_filter :get_notice, :except => [:index, :create, :new]
      
  # Session Variables
  INDEX_KEY_LIST_VAR        = "notice_list_cache_var"
      
  def index

    @notices = Notice.all   
    # cache the set of asset ids in case we need them later
    cache_list(@notices, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @notices }
    end
  end

  def show

    add_breadcrumb @notice.name, notice_path(@notice)

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@notice, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : notice_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : notice_path(@next_record_key)
    
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render :json => @notice }
    end
  end

  
  def new

    add_breadcrumb "New"

  end

  def edit
    
    add_breadcrumb @notice.name, notice_path(@notice)
    add_breadcrumb "Update"
    
  end
  
  def create

    @notice = Notice.new(form_params)

    respond_to do |format|
      if @notice.save
        notify_user(:notice, "Notice was successfully created.")
        format.html { redirect_to notice_url(@notice) }
        format.json { render :json => @notice, :status => :created, :location => @notice }
      else
        format.html { render :action => "new" }
        format.json { render :json => @notice.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    add_breadcrumb @notice.name, notice_path(@notice)
    add_breadcrumb "Update"

    respond_to do |format|
      if @notice.update_attributes(form_params)
        notify_user(:notice, "Notice was successfully updated.")
        format.html { redirect_to notice_url(@notice) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
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
    params.require(:notice).permit(notice_allowable_params)
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
