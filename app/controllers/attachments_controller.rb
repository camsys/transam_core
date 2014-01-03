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

    @page_title = 'Attachments'
    
     # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)
   
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @attachments}
    end

  end

  def download
    
    if @attachment.nil?
      redirect_to(inventory_attachments_url(@asset), :flash => { :alert => 'Record not found!'})
      return            
    end
    # send the attachment    
    send_data @attachment.file, :filename => @attachment.original_filename

  end
  
  def show
  
    if @attachment.nil?
      redirect_to(inventory_attachments_url(@asset), :flash => { :alert => 'Record not found!'})
      return            
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @attachment}
    end

  end

  def create      

    @page_title = "Upload Attachment"

    @attachment = Attachment.new(form_params)
    @attachment.asset = @asset
    
    respond_to do |format|
      if @attachment.save        
        format.html { redirect_to inventory_attachments_url(@asset), :notice => "Attachment was successfully uploaded." }
        format.json { render :json => @attachment, :status => :created, :location => @attachment }
      else
        format.html { render :action => "new" }
        format.json { render :json => @attachment.errors, :status => :unprocessable_entity }
      end
    end
    
  end

  def edit

    if @attachment.nil?
      redirect_to(inventory_attachments_url(@asset), :flash => { :alert => 'Record not found!'})
      return            
    end
    @page_title = @attachment.name
  end
  
  def update

    if @attachment.nil?
      redirect_to(inventory_attachments_url(@asset), :flash => { :alert => 'Record not found!'})
      return            
    end
    @page_title = @attachment.name

    respond_to do |format|
      if @attachment.update_attributes(form_params)
        format.html { redirect_to inventory_attachment_url(@asset, @attachment), :notice => "Attachment was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @attachment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def new

    @attachment = Attachment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @attachment }
    end
    
  end

  def destroy

    if @attachment.nil?
      redirect_to(inventory_attachments_url(@asset), :flash => { :alert => 'Record not found!'})
      return      
    end

    @attachment.destroy

    respond_to do |format|
      format.html { redirect_to(inventory_attachments_url(@asset), :flash => { :notice => 'Attachment was successfully removed.'}) } 
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
        redirect_to(inventory_url, :flash => { :alert => 'Record not found!'})
        return      
      end
      redirect_to inventory_attachments_url(@asset)
    end
  end
    
end
