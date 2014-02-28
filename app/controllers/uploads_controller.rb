class UploadsController < OrganizationAwareController

  before_action :set_upload, :only => [:show, :destroy]  
  before_filter :check_for_cancel, :only => [:create, :update]
  
  SESSION_VIEW_TYPE_VAR = 'uploads_subnav_view_type'
  
  def index

    @page_title = 'File Uploads'
    @uploads = current_user.uploads

    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @uploads }
    end

  end

  def show
    
    @page_title = "Spreadsheet: #{@upload.original_filename}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @upload }
    end
    
  end

  def templates
    @page_title = "Download Template"
    
  end
  
  def create_templates
    
  end
  
  def new
    
    @page_title = "Upload Spreadsheet"
    @upload = Upload.new
    
  end
  
  def create

    @page_title = "Upload Spreadsheet"

    @upload = Upload.new(form_params)
    @upload.user = current_user
    @upload.customer = current_user.organization.customer
    
    respond_to do |format|
      if @upload.save
        notify_user(:notice, "File was successfully uploaded.")        
        format.html { redirect_to uploads_url }
        format.json { render :json => @upload, :status => :created, :location => @upload }
      else
        format.html { render :action => "new" }
        format.json { render :json => @upload.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy

    if @upload.nil?
      notify_user(:alert, "Record not found!")
      redirect_to files_url
      return      
    end

    @upload.destroy
    notify_user(:notice, "File was successfully removed.")

    respond_to do |format|
      format.html { redirect_to(uploads_url) } 
      format.json { head :no_content }
    end
  end

  protected
  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:upload).permit(upload_allowable_params)
  end
  
  # Callbacks to share common setup or constraints between actions.
  def set_upload
    @upload = Upload.find_by_object_key(params[:id]) unless params[:id].nil?
  end
  
  private
  
  def check_for_cancel
    unless params[:cancel].blank?
      redirect_to uploads_url
    end
  end
  
end
