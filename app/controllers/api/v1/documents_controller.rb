class Api::V1::DocumentsController < Api::V1::NestedResourceController
  before_action :set_documentable, :only => [:index, :create]
  before_action :set_document, :only => [:show, :update, :destroy]
  
  # GET /documents.json
  def index
    @documents = @documentable.documents
  end

  # GET /documents/1.json
  def show 
  end

  # POST /documents.json
  def create
    @document = @documentable.documents.build(form_params)
    @document.creator = current_user
    unless @document.save
      @status = :fail
      @message  = "Unable to upload document due the following error: #{@document.errors.messages}" 
      render status: 400, json: json_response(:fail, message: @message)
    end
  end

  # PATCH/PUT /documents/1.json
  def update
    unless @document.update(form_params)
      @status = :fail
      @message  = "Unable to update document due the following error: #{@document.errors.messages}" 
      render status: 400, json: json_response(:fail, message: @message)
    end
  end

  # DELETE /documents/1.json
  def destroy
    unless @document.destroy
      @status = :fail
      @message  = "Unable to destroy document due the following error: #{@document.errors.messages}" 
      render status: 400, json: json_response(:fail, message: @message)
    end
  end

  private

  def set_documentable
    @documentable = find_resource
    unless @documentable
      @status = :fail
      @data = {id: "Documentable object not found."}
      render status: :not_found, json: json_response(:fail, data: @data)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_document
    @document = Document.find_by(:object_key => params[:id])

    unless @document
      @status = :fail
      @data = {id: "Document #{params[:id]} not found."}
      render status: :not_found, json: json_response(:fail, data: @data)
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.permit(Document.allowable_params)
  end

end
