class DocumentsController < OrganizationAwareController
  before_action :set_document, :only => [:edit, :update, :destroy, :download]

  # GET /documents
  # GET /documents.json
  def index
       
    @documentable = find_documentable
    @documents = @documentable.documents
  
    @page_title = "#{@documentable.project_number}: Documents"

  end

  # GET /documents/new
  def new
    @document = Document.new
    @documentable = find_documentable
    @page_title = "#{@documentable.project_number}: New document"
    
  end

  # GET /documents/1/edit
  def edit

    @documentable = @document.documentable
    @page_title = "#{@documentable.project_number}: Edit document"

  end

  def download
    
    if @document.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to( root_path )
      return            
    end
    # send the attachment    
    send_data @document.document, :filename => @document.original_filename

  end

  # POST /documents
  # POST /documents.json
  def create
    @documentable = find_documentable
    @document = @documentable.documents.build(document_params)
    @document.creator = current_user

    @page_title = "#{@documentable.project_number}: New document"
    
    respond_to do |format|
      if @document.save
        notify_user(:notice, 'Document was successfully created.')
        url = "#{@documentable.class.name.underscore}_url('#{@documentable.object_key}')"   
        format.html { redirect_to eval(url) }
        format.json { render action: 'show', status: :created, location: @document }
      else
        format.html { render action: 'new' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update

    @documentable = @document.documentable
    @page_title = "#{@documentable.project_number}: Edit document"

    respond_to do |format|
      if @document.update(document_params)
        notify_user(:notice, 'Document was successfully updated.')   
        url = "#{@documentable.class.name.underscore}_url('#{@documentable.object_key}')"   
        format.html { redirect_to eval(url) }
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
      url = "#{@documentable.class.name.underscore}_url('#{@documentable.object_key}')"   
      format.html { redirect_to eval(url) }
      format.json { head :no_content }
    end
  end

  private

  # Get the class and object key of the documentable object we are operating on
  def find_documentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find_by_object_key(value)
      end
    end
    
    nil
  end
    
  # Use callbacks to share common setup or constraints between actions.
  def set_document
    @document = Document.find_by_object_key(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(document_allowable_params)
  end

end
