class AttachmentsController < AssetAwareController
    
  before_action :set_attachment,    :only => [:show, :edit, :update, :destroy, :download]  
  before_filter :check_for_cancel,  :only => [:create, :update]

  # always use generic untyped assets for this controller
  RENDER_TYPED_ASSETS = false

  SESSION_VIEW_TYPE_VAR = 'attachments_subnav_view_type'

  # always render untyped assets for this controller
  def render_typed_assets
    RENDER_TYPED_ASSETS
  end

  def index

    # Check to see if we got an filter to sub select on
    if params[:filter_type].nil? 
      # see if one is stored in the session
      @filter_type = session[:filter_type].nil? ? 0 : session[:filter_type]
    else
      @filter_type = params[:filter_type].to_i
    end
    # store it in the session
    session[:filter_type] = @filter_type

    if @filter_type > 0
      @attachments = @asset.attachments.where("attachment_type_id = ?", @filter_type).order('created_at')
    else
      @attachments = @asset.attachments.order('attachment_type_id, created_at')
    end

    @page_title = "#{@asset.name}: Attachments"
    
     # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)
   
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @attachments}
    end

  end

  def download
    
    if @attachment.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_attachments_url(@asset))
      return            
    end
    # send the attachment    
    send_data @attachment.file, :filename => @attachment.original_filename

  end
  
  def show
  
    if @attachment.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_attachments_url(@asset))
      return            
    end

    @page_title = "#{@asset.name}: #{@attachment.attachment_type.name}: #{@attachment.name}"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @attachment}
    end

  end

  def create      

    @attachment = Attachment.new(form_params)
    @attachment.asset = @asset
    
    respond_to do |format|
      if @attachment.save        
        notify_user(:notice, "Attachment was successfully uploaded.")
        format.html { redirect_to inventory_attachments_url(@asset) }
        format.json { render :json => @attachment, :status => :created, :location => @attachment }
      else
        format.html { render :action => "new" }
        format.json { render :json => @attachment.errors, :status => :unprocessable_entity }
      end
    end
    
  end

  def edit

    if @attachment.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_attachments_url(@asset))
      return            
    end

    @page_title = "#{@asset.name}: Update: #{@attachment.name}"
  end
  
  def update

    if @attachment.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_attachments_url(@asset))
      return            
    end
    @page_title = @attachment.name

    respond_to do |format|
      if @attachment.update_attributes(form_params)
        notify_user(:notice, "Attachment was successfully updated.")
        format.html { redirect_to inventory_attachment_url(@asset, @attachment)}
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @attachment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def new

    @page_title = "#{@asset.name}: New Attachment"

    @attachment = Attachment.new
    @attachment.attachment_type_id = 1

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @attachment }
    end
    
  end

  def destroy

    if @attachment.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_attachments_url(@asset))
      return      
    end

    @attachment.destroy

    notify_user(:notice, 'Attachment was successfully removed.')

    respond_to do |format|
      format.html { redirect_to(inventory_attachments_url(@asset)) } 
      format.json { head :no_content }
    end
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  def set_attachment
    @attachment = @asset.attachments.find_by_object_key(params[:id]) unless params[:id].nil?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:attachment).permit(attachment_allowable_params)
  end
  
  def check_for_cancel
    unless params[:cancel].blank?
      get_asset
      if @asset.nil?
        notify_user(:alert, 'Record not found!')
        redirect_to(inventory_url)
        return      
      end
      redirect_to inventory_attachments_url(@asset)
    end
  end
    
end
