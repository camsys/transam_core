class ManufacturersController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  def index

    add_breadcrumb "Manufacturers", manufacturers_path

    # get the manufacturers for this agency
    count_hash = @organization.manufacturer_counts
    @manufacturers = Manufacturer.where(:id => count_hash.keys)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @manufacturers }
    end
  end

  protected

  private

end
