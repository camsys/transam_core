class UploadsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  before_action :set_upload, :only => [:show, :destroy, :resubmit]  
  before_filter :check_for_cancel, :only => [:create, :update, :create_template]
    
  def index

    add_breadcrumb "Uploads", uploads_path
    
    # Start to set up the query
    conditions  = []
    values      = []
    
    # Add the organization clause
    conditions << 'organization_id IN (?)'
    values << get_id_array(current_user.organizations)
    
    # See if we got an organization type id
    @file_status_type_id = params[:file_status_type_id]
    unless @file_status_type_id.blank?
      @file_status_type_id = @file_status_type_id.to_i
      conditions << 'file_status_type_id = ?'
      values << @file_status_type_id
      
      type = FileStatusType.find(@file_status_type_id)
      add_breadcrumb type.name unless type.nil?
    end

    @uploads = Upload.where(conditions.join(' AND '), *values).order(:created_at)
        
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @uploads }
    end

  end

  def show
    
    if @upload.nil?
      notify_user(:alert, "Record not found!")
      redirect_to uploads_url
      return      
    end

    add_breadcrumb "Uploads", uploads_path
    add_breadcrumb @upload.original_filename
        
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @upload }
    end
    
  end

  # Reload the worksheet. This action pushes the spreadsheet back into the queue
  # to be processed
  def resubmit
    
    if @upload.nil?
      notify_user(:alert, "Record not found!")
      redirect_to uploads_url
      return      
    end
    
    # Make sure the force flag is set and that the model is set back to
    # unprocessed
    @upload.reset
    @upload.force_update = true
    @upload.save
    
    notify_user(:notice, "File was resubmitted for processing.")        
    # create a job to process this file in the background
    create_upload_process_job(@upload)
    
    respond_to do |format|
      format.html { render 'show' }
      format.json { render :json => @upload }
    end
    
  end

  def templates
    
    add_breadcrumb "Templates", templates_uploads_path
    add_breadcrumb "Download Template"
        
    #prepare a list of just the asset types of the current organization
    @asset_types = []
    AssetType.all.each do |at|
      count = Asset.where('organization_id in (?) AND asset_type_id = ?', get_id_array(current_user.organizations), at.id).count
      if count > 0 
        @asset_types << at
      end
    end
  end
  
  def create_template

    add_breadcrumb "Templates", templates_uploads_path
    add_breadcrumb "Download Template"
    
    template_proxy = TemplateProxy.new(params[:template_proxy])
    file_content_type = FileContentType.find(template_proxy.file_content_type_id)
    if template_proxy.valid?
      # Find out which builder is used to construct the template and create an instance
      builder = file_content_type.builder_name.constantize.new
      builder.organization = @organization
      builder.asset_types = [template_proxy.asset_type]
      
      # Generate the spreadsheet. This returns a StringIO that has been rewound
      stream = builder.build

      # Send it to the user
      filename = "#{@organization.short_name.downcase}_#{file_content_type.class_name.underscore}_#{Date.today}.xls"
      send_data stream.string, :filename => filename, :type => "application/vnd.ms-excel"
    else
      respond_to do |format|
        format.html { render :action => "templates" }
      end
    end
        
  end
  
  def new

    add_breadcrumb "Uploads", uploads_path
    add_breadcrumb "New"
    
    @upload = Upload.new
    
  end
  
  #
  # Create a new upload. If the current user has a list of organizations, they can create
  # an upload for any organization in their list
  #
  def create

    @upload = Upload.new(form_params)
    @upload.user = current_user
    if @upload.organization.nil?
      @upload.organization = @organization
    end

    add_breadcrumb "Uploads", uploads_path
    add_breadcrumb "New"
    
    respond_to do |format|
      if @upload.save
        notify_user(:notice, "File was successfully uploaded.")        
        # create a job to process this file in the background
        create_upload_process_job(@upload)

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
      redirect_to uploads_url
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
  
  # Generates a background job to propcess the file
  def create_upload_process_job(upload, priority = 0)
    if upload
      job = UploadProcessorJob.new(upload.object_key)
      fire_background_job(job, priority)
    end
  end
  
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
