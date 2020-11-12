class DocumentsController < NestedResourceController
  before_action :set_document, :only => [:edit, :update, :destroy, :download]
  before_action :format_dates, :only => [:create, :update]

  # Lock down the controller
  authorize_resource only: [:index, :new, :create, :edit, :update, :destroy]

  # GET /documents
  # GET /documents.json
  def index

    @documentable = find_resource
    @documents = @documentable.documents

  end

  # GET /documents/new
  def new
    @document = Document.new
    @documentable = find_resource
  end

  # GET /documents/1/edit
  def edit

    @documentable = @document.documentable

  end

  def download

    if @document.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to( root_path )
      return
    end
    # read the attachment
    content = open(@document.document.url, "User-Agent" => "Ruby/#{RUBY_VERSION}") {|f| f.read}
    # Send to the client
    send_data content, :filename => @document.original_filename

  end

  # POST /documents
  # POST /documents.json
  def create
    @documentable = find_resource
    @document = @documentable.documents.build(document_params)
    @document.creator = current_user

    respond_to do |format|
      if @document.save
        notify_user(:notice, 'Document was successfully created.')
        format.html { redirect_back(fallback_location: root_path) }
        format.json { render action: 'show', status: :created, location: @document }
        format.js { @asset = @document.documentable }
      else
        format.html { render action: 'new' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
        format.js { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update

    @documentable = @document.documentable

    respond_to do |format|
      if @document.update(document_params)
        notify_user(:notice, 'Document was successfully updated.')
        format.html { redirect_to get_resource_url(@documentable) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy

    @documentable = @document.documentable
    @document.destroy

    notify_user(:notice, 'Document was successfully removed.')
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_document
    @document = Document.find_by(:object_key => params[:id])
    if @document.nil?
      redirect_to '/404'
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(Document.allowable_params)
  end

  def format_dates
    params[:document].select{|p| p.end_with?("_date")}.each do |p|
      unless p[1].match(/\A\d{4}-\d{2}-\d{2}\z/)
        params[:document][p[0]] = Date.strptime(p[1], '%m/%d/%Y').strftime('%Y-%m-%d')
      end
    end
  end

end
