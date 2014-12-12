class VendorsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Vendors", :vendors_path

  before_action :set_vendor, only: [:show, :edit, :update, :destroy]

  # Session Variables
  INDEX_KEY_LIST_VAR        = "vendors_list_cache_var"

  # GET /vendors
  def index

    # Start to set up the query
    conditions  = []
    values      = []

    # Limit to the org
    conditions << 'organization_id = ?'
    values << @organization.id

    @vendors = Vendor.where(conditions.join(' AND '), *values)

    # cache the vendor ids in case we need them later
    cache_list(@vendors, INDEX_KEY_LIST_VAR)

  end

  # GET /vendors/1
  def show

    add_breadcrumb @vendor

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@vendor, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : vendor_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : vendor_path(@next_record_key)

  end

  # GET /vendors/new
  def new

    add_breadcrumb "New", new_vendor_path

    @vendor = Vendor.new

  end

  # GET /vendors/1/edit
  def edit

    add_breadcrumb @vendor.name, vendor_path(@vendor)
    add_breadcrumb "Update"

  end

  # POST /vendors
  # POST /vendors.json
  def create

    add_breadcrumb "New", new_vendor_path

    @vendor = Vendor.new(vendor_params)
    @vendor.organization = @organization

    respond_to do |format|
      if @vendor.save
        notify_user(:notice, "The vendor was successfully saved.")
        format.html { redirect_to vendor_url(@vendor) }
        format.json { render action: 'show', status: :created, location: @vendor }
      else
        format.html { render action: 'new' }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vendors/1
  # PATCH/PUT /vendors/1.json
  def update

    add_breadcrumb @vendor.name, vendor_path(@vendor)
    add_breadcrumb "Update"

    respond_to do |format|
      if @vendor.update(vendor_params)
        notify_user(:notice, "The vendor was successfully updated.")
        format.html { redirect_to vendor_url(@vendor) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @vendor.assets.count == 0 && @vendor.expenditures.count == 0
      @vendor.destroy
      redirect_to vendors_url, notice: 'Vendor was successfully destroyed.'
    else
      redirect_to @vendor, notice: 'Vendor cannot be destroyed as there are assets and expenditures associated with it.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
      @vendor = Vendor.find_by(:object_key => params[:id])
    end

    def vendor_params
      params.require(:vendor).permit(Vendor.allowable_params)
    end

end
