class ImagesController < NestedResourceController
  before_action :set_image, :only => [:edit, :update, :destroy, :download]

  # Lock down the controller
  authorize_resource only: [:index, :new, :create, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index

    @imagable = find_resource
    @images = @imagable.images

  end

  # GET /images/new
  def new
    @image = Image.new
    @imagable = find_resource

  end

  # GET /images/1/edit
  def edit

    @imagable = @image.imagable

  end

  def download

    if @image.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to( root_path )
      return
    end
    # read the attachment
    content = open(@image.image.url, "User-Agent" => "Ruby/#{RUBY_VERSION}") {|f| f.read}
    # Send to the client
    send_data content, :filename => @image.original_filename

  end

  # POST /images
  # POST /images.json
  def create
    @imagable = find_resource
    @image = @imagable.images.build(form_params)
    @image.creator = current_user
    
    respond_to do |format|
      if @image.save
        notify_user(:notice, 'Image was successfully created.')
        format.html { redirect_back(fallback_location: root_path) }
        format.json { render action: 'show', status: :created, location: @image }
      else
        format.html { render action: 'new' }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update

    @imagable = @image.imagable

    respond_to do |format|
      if @image.update(form_params)
        notify_user(:notice, 'Image was successfully updated.')
        format.html { redirect_to get_resource_url(@imagable) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy

    @imagable = @image.imagable
    @image.destroy

    notify_user(:notice, 'Image was successfully removed.')
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find_by(:object_key => params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:image).permit(Image.allowable_params)
  end

end
