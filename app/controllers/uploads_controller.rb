class UploadsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Bulk Updates", :uploads_path

  before_action :set_upload, :only => [:show, :destroy, :resubmit, :undo, :download]

  # Session Variables
  INDEX_KEY_LIST_VAR        = "uploads_key_list_cache_var"

  def index

    # Start to set up the query
    conditions  = []
    values      = []

    # Add the organization clause
    conditions << 'organization_id IN (?)'
    values << @organization_list

    # See if we got an organization type id
    @file_status_type_id = params[:file_status_type_id]
    unless @file_status_type_id.blank?
      @file_status_type_id = @file_status_type_id.to_i
      conditions << 'file_status_type_id = ?'
      values << @file_status_type_id

      type = FileStatusType.find(@file_status_type_id)
      add_breadcrumb type.name unless type.nil?
    end

    asset_ids = Asset.where('organization_id IN (?) AND upload_id IS NOT NULL', @organization_list).pluck(:upload_id)
    @uploads = Upload.where('('+conditions.join(' AND ')+') OR id IN (?) OR user_id = ?', *values, asset_ids, current_user.id).order(:created_at)

    # cache the set of asset ids in case we need them later
    cache_list(@uploads, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @uploads }
    end

  end

  def download

    if @upload.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to( root_path )
      return
    end
    # read the attachment
    content = open(@upload.file.url, "User-Agent" => "Ruby/#{RUBY_VERSION}") {|f| f.read}
    # Send to the client
    send_data content, :filename => @upload.original_filename

  end

  def show

    if @upload.nil?
      notify_user(:alert, "Record not found!")
      redirect_to uploads_url
      return
    end

    add_breadcrumb @upload.original_filename

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@upload, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : upload_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : upload_path(@next_record_key)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @upload }
    end

  end

  # Undo events created from the worksheet.
  def undo

    if @upload.nil?
      notify_user(:alert, "Record not found!")
      redirect_to uploads_url
      return
    end

    # cache affected assets
    affected_assets = @upload.asset_events.map(&:asset).uniq

    @upload.reset
    @upload.update(file_status_type: FileStatusType.find_by(name: "Reverted"))

    # re-update the assets which previously had events
    affected_assets.each do |affected|
      job = AssetUpdateJob.new(affected.object_key)
      fire_background_job(job)
    end


    notify_user(:notice, "Upload has been reverted.")

    # show the original upload
    redirect_to(upload_url(@upload))

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
    # unprocessed.  reset destroys dependent asset_events
    @upload.reset
    @upload.save(:validate => false)

    notify_user(:notice, "File was resubmitted for processing.")

    # create a job to process this file in the background
    create_upload_process_job(@upload)

    # show the original upload
    redirect_to(upload_url(@upload))

  end

  #-----------------------------------------------------------------------------
  # Display the download template form. User can select the type of update they
  # want and the list of asset types
  #-----------------------------------------------------------------------------
  def templates

    add_breadcrumb "Download Template"

    @message = "Creating inventory template. This process might take a while."

    # Prepare a list of the asset types for the current organization list where at least
    # one asset type is operational
    @asset_types = []
    #@organization.asset_type_counts.each{|x| @asset_types << AssetType.find(x[0])}

    AssetType.all.each do |type|
      assets = Asset.where(asset_type: type)
      @asset_types << {id: type.id, name: type.to_s, orgs: @organization_list.select{|o| assets.where(organization_id: o).count > 0}}
    end

  end

  #-----------------------------------------------------------------------------
  # Send a file to the user
  #-----------------------------------------------------------------------------
  def download_file

    # Send it to the user
    filename = params[:filename]
    filepath = params[:filepath]
    data = File.read(filepath)
    send_data data, :filename => filename, :type => "application/vnd.ms-excel"

  end

  #-----------------------------------------------------------------------------
  # Creates a spreadsheet template for bulk updating assets. There are two pathways
  # to this method:
  #
  # template form -- sets the params[:template] param
  # from an asset group -- sets the params[:file_content_type] param
  #
  #-----------------------------------------------------------------------------
  def create_template

    add_breadcrumb "Download Template"

    # Figure out which approach was used to access this method
    from_form = true
    file_content_type = nil
    # From the form. This is managed via a TemplateProxy class
    if params[:template_proxy].present?
      # Inflate the proxy
      template_proxy = TemplateProxy.new(params[:template_proxy])
      Rails.logger.debug template_proxy.inspect

      # See if an org was set, use the default otherwise
      if template_proxy.organization_id.blank?
        org = nil
      else
        o = Organization.find(template_proxy.organization_id)
        org = Organization.get_typed_organization(o)
      end

      # The form defines the FileContentType which identifies the builder to use
      file_content_type = FileContentType.find(template_proxy.file_content_type_id)
      # asset_types are an array of asset types
      asset_types = [AssetType.find(template_proxy.asset_type_id)]

    elsif params[:targets].present?
      from_form = false
      # The request came from the audit results page. We have a list of asset
      # object keys
      file_content_type = FileContentType.find(params[:file_content_type_id])
      assets = Asset.operational.where(:object_key => params[:targets].split(','))
      asset_types = AssetType.where(:id => assets.pluck(:asset_type_id).uniq)
      org = @organization
    end

    # Find out which builder is used to construct the template and create an instance
    builder = file_content_type.builder_name.constantize.new(:organization => org, :asset_types => [*asset_types], :organization_list => @organization_list)

    # Generate the spreadsheet. This returns a StringIO that has been rewound
    if from_form
      asset_params = {}
      asset_params[:organization] = org
      asset_params[:asset_type] = asset_types
      asset_params[:object_key] = params[:ids] if params[:ids]
    else
      builder.assets = assets
    end
    stream = builder.build

    # Save the template to a temporary file and render a success/download view
    file = Tempfile.new ['template', '.tmp'], "#{Rails.root}/tmp"
    ObjectSpace.undefine_finalizer(file)
    #You can uncomment this line when debugging locally to prevent Tempfile from disappearing before download.
    @filepath = file.path
    @filename = "#{org.present? ? org.short_name.downcase : 'MultiOrg'}_#{file_content_type.class_name.underscore}_#{Date.today}.xlsx"
    begin
      file << stream.string
    rescue => ex
      Rails.logger.warn ex
    ensure
      file.close
    end
    # Ensure you're cleaning up appropriately...something wonky happened with
    # Tempfiles not disappearing during testing
    respond_to do |format|
      format.js
      format.html
    end

  end

  def new

    add_breadcrumb "New Template"

    @upload = Upload.new

  end

  #-----------------------------------------------------------------------------
  # Create a new upload. If the current user has a list of organizations, they can create
  # an upload for any organization in their list
  #-----------------------------------------------------------------------------
  def create

    @upload = Upload.new(form_params)
    @upload.user = current_user

    add_breadcrumb "New Template"

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
    params.require(:upload).permit(Upload.allowable_params)
  end

  # Callbacks to share common setup or constraints between actions.
  def set_upload
    @upload = Upload.find_by_object_key(params[:id]) unless params[:id].nil?
    if @upload.nil?
      redirect_to '/404'
      return
    end
  end

  private

end
