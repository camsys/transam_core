class Api::V1::ImagesController < Api::V1::NestedResourceController
  before_action :set_imagable, :only => [:index, :create]
  before_action :set_image, :only => [:show, :update, :destroy]
  
  # GET /images.json
  def index
    @images = @imagable.images
  end

  # GET /images/1.json
  def show 
  end

  # POST /images.json
  def create
    @image = @imagable.images.build(form_params)
    @image.creator = current_user
    unless @image.save
      @status = :fail
      @message  = "Unable to upload image due the following error: #{@image.errors.messages}" 
      render status: 400, json: json_response(:fail, message: @message)
    end
  end

  # PATCH/PUT /images/1.json
  def update
    unless @image.update(form_params)
      @status = :fail
      @message  = "Unable to update image due the following error: #{@image.errors.messages}" 
      render status: 400, json: json_response(:fail, message: @message)
    end
  end

  # DELETE /images/1.json
  def destroy
    unless @image.destroy
      @status = :fail
      @message  = "Unable to destroy image due the following error: #{@image.errors.messages}" 
      render status: 400, json: json_response(:fail, message: @message)
    end
  end

  private

  def set_imagable
    @imagable = find_resource
    unless @imagable
      @status = :fail
      @data = {id: "Imagable object not found."}
      render status: :not_found, json: json_response(:fail, data: @data)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find_by(:object_key => params[:id])

    unless @image
      @status = :fail
      @data = {id: "Image #{params[:id]} not found."}
      render status: :not_found, json: json_response(:fail, data: @data)
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.permit(Image.allowable_params)
  end

end
