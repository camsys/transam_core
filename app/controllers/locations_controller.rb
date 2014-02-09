class LocationsController < OrganizationAwareController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  # include the transam markers mixin
  include TransamMapMarkers

  SESSION_VIEW_TYPE_VAR = 'locations_subnav_view_type'

  # GET /locations
  # GET /locations.json
  def index
    
    @page_title = 'Locations'
    @locations = @organization.`locations

    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)

    # If we are building a map, make sure we get the map artifacts
    if @view_type == VIEW_TYPE_MAP
      @markers = generate_map_markers(@locations)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @locations }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show

    # if not found or the object does not belong to the user's organization
    # send them back to index.html.erb
    if @location.nil?
      notify_user(:alert, "Record not found!")
      redirect_to locations_url
      return
    end
    @page_title = "Location: #{@location.name}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @location }
    end

  end

  # GET /locations/new
  def new
    @location = Location.new
    @page_title = 'New Location'
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @location }
    end
    
  end

  # GET /locations/1/edit
  def edit
    # if not found or the object does not belong to the user's organization
    # send them back to index.html.erb
    if @location.nil?
      notify_user(:alert, "Record not found!")
      redirect_to locations_url
      return
    end
    @page_title = "Update: #{@location.name}"
    
  end

  # POST /locations
  # POST /locations.json
  def create

    @location = Location.new(location_params)
    @location.organization = @organization
    
    respond_to do |format|
      if @location.save
        notify_user(:notice, "Location was successfully created.")
        format.html { redirect_to @location }
        format.json { render action: 'show', status: :created, location: @location }
      else
        format.html { render action: 'new' }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @location.nil?
      notify_user(:alert, "Record not found!")
      redirect_to locations_url
      return
    end

    respond_to do |format|
      if @location.update(location_params)
        notify_user(:notice, "Location was successfully updated.")
        format.html { redirect_to @location }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    # if not found or the object does not belong to the user's organization
    # send them back to index.html.erb
    if @location.nil?
      notify_user(:alert, "Record not found!")
      redirect_to locations_url
      return
    end

    @location.destroy
    respond_to do |format|
      notify_user(:notice, "Location was successfully removed.")
      format.html { redirect_to locations_url }
      format.json { head :no_content }
    end
  end
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected
    #
    # generate an array of map markers for use with the leaflet plugin
    #
    def generate_map_markers(locations_array, render_open = false)
      objs = []
      locations_array.each do |loc|
        objs << get_location_marker(loc, render_open) unless loc.latitude.nil?
      end
      return objs.to_json    
    end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = @organization.locations.find_by_object_key(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(location_allowable_params)
    end
end
