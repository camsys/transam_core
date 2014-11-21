class VendorsController < OrganizationAwareController
  
  add_breadcrumb "Home", :root_path
  add_breadcrumb "Vendors", :vendors_path
  
  before_action :set_vendor, only: [:show]

  # Session Variables
  INDEX_KEY_LIST_VAR        = "vendors_list_cache_var"

  # GET /expenditures
  def index

    # Start to set up the query
    conditions  = []
    values      = []
    
    # Limit to the org
    conditions << 'organization_id = ?'
    values << @organization.id
        
    @vendors = Vendor.where(conditions.join(' AND '), *values) 

    # cache the expenditure ids in case we need them later
    cache_list(@vendors, INDEX_KEY_LIST_VAR)

  end

  # GET /expenditures/1
  def show

    add_breadcrumb @vendor

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@vendor, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : vendor_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : vendor_path(@next_record_key)
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
      @vendor = Vendor.find_by(:object_key => params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def expenditure_params
      params.require(:vendor).permit(Vendor.allowable_params)
    end
end
