class ManufacturersController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  def index

    add_breadcrumb "Manufacturers", manufacturers_path

    @manufacturers = Manufacturer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @manufacturers }
    end
  end

  protected

  private

end
